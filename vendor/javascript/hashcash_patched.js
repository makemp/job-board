// A modern, secure, and performant implementation of client-side Hashcash.
// NOTE: This is useless without mandatory server-side validation.

const Hashcash = function(input) {
  //console.log("Hashcash constructor called for input:", input);
  const options = JSON.parse(input.getAttribute("data-hashcash"));
  Hashcash.disableParentForm(input, options);
  input.dispatchEvent(new CustomEvent("hashcash:mint", { bubbles: true }));

  // Keep track of the start time for performance measurement.
  const startedAt = performance.now();

  Hashcash.mint(options.resource, options, function(stamp) {
   // console.log("Callback received from worker with solved stamp:", stamp);
    // Attach performance metrics to the final stamp object.
    stamp.startedAt = startedAt;
    stamp.endedAt = performance.now();
    stamp.logPerformance();

    input.value = stamp.toString();
    Hashcash.enableParentForm(input, options);
    input.dispatchEvent(new CustomEvent("hashcash:minted", { bubbles: true, detail: { stamp: stamp } }));
  });

  this.input = input;
  input.form.addEventListener("submit", this.preventFromAutoSubmitFromPasswordManagers.bind(this));
};

/**
 * Scans the document for any new hashcash inputs that have not yet been initialized.
 * This function is designed to be called multiple times.
 */
Hashcash.initializeNewInputs = function() {
  // Find all inputs that have the attribute but have not been initialized.
  const inputs = document.querySelectorAll("input[data-hashcash]:not([data-hashcash-initialized])");

  //if (inputs.length > 0) {
  //  console.log(`Found ${inputs.length} new hashcash input(s). Initializing.`);
  //}

  inputs.forEach(input => {
    // Mark as initialized to prevent running twice on the same element.
    input.setAttribute("data-hashcash-initialized", "true");
    new Hashcash(input);
  });
};


/**
 * Sets up a single, robust listener to detect and initialize hashcash inputs,
 * including those added dynamically by frameworks like Turbo.
 */
Hashcash.setup = function() {
  //console.log("1. Hashcash.setup() called. Setting up MutationObserver.");

  // Use a MutationObserver to catch all dynamic additions to the page,
  // including initial load, Turbo Drive, and Turbo Streams. This is the most
  // reliable method for modern JavaScript frameworks.
  const observer = new MutationObserver(() => {
    // This callback fires whenever nodes are added or removed.
    // We just re-run our scan. The `data-hashcash-initialized` attribute
    // prevents re-initializing inputs that are already running.
    Hashcash.initializeNewInputs();
  });

  // Start observing the entire document for changes to its structure.
  observer.observe(document.documentElement, { childList: true, subtree: true });

  // Perform an initial scan in case the script loads after the DOM is already ready.
  // This handles the very first page load.
  if (document.readyState === "complete" || document.readyState === "interactive") {
    Hashcash.initializeNewInputs();
  } else {
    document.addEventListener("DOMContentLoaded", () => Hashcash.initializeNewInputs(), { once: true });
  }
};


Hashcash.setSubmitText = function(submit, text) {
  if (!text) return;
  if (submit.tagName === "BUTTON") {
    if (!submit.originalValue) submit.originalValue = submit.innerHTML;
    submit.innerHTML = text;
  } else {
    if (!submit.originalValue) submit.originalValue = submit.value;
    submit.value = text;
  }
};

Hashcash.disableParentForm = function(input, options) {
  input.form.querySelectorAll("[type=submit]").forEach(function(submit) {
    Hashcash.setSubmitText(submit, options["waiting_message"]);
    submit.disabled = true;
  });
};

Hashcash.enableParentForm = function(input, options) {
  input.form.querySelectorAll("[type=submit]").forEach(function(submit) {
    Hashcash.setSubmitText(submit, submit.originalValue);
    submit.disabled = false; // Use false for clarity.
  });
};

Hashcash.prototype.preventFromAutoSubmitFromPasswordManagers = function(event) {
  if (this.input.value === "") {
    event.preventDefault();
  }
};

Hashcash.default = {
  version: 1,
  bits: 16, // Reduced from 20 to 16 for better mobile compatibility
  extension: null,
  worker_path: '/hashcash-worker.js' // Path to your worker script.
};

// Generates a cryptographically secure random string.
Hashcash.secureRandom = function() {
  const buffer = new Uint8Array(16);
  crypto.getRandomValues(buffer);
  return Array.from(buffer, byte => byte.toString(16).padStart(2, '0')).join('');
};

Hashcash.mint = function(resource, options, callback) {
  /// ("Minting called. Attempting to create worker from path:", options.worker_path || Hashcash.default.worker_path);

  try {
    const worker = new Worker(options.worker_path || Hashcash.default.worker_path);

    // Format date to YYMMDD
    const date = new Date();
    const year = date.getFullYear().toString().slice(-2);
    const month = (date.getMonth() + 1).toString().padStart(2, "0");
    const day = date.getDate().toString().padStart(2, "0");

    const stampData = {
      version: options.version || Hashcash.default.version,
      bits: options.bits || Hashcash.default.bits,
      date: options.date || `${year}${month}${day}`,
      resource: resource,
      extension: options.extension || Hashcash.default.extension,
      rand: options.rand || Hashcash.secureRandom(),
    };

    // Listen for the solved stamp from the worker.
    worker.onmessage = function(e) {
      // console.log("Message received from worker:", e.data);
      const solvedStamp = Hashcash.Stamp.parse(e.data);
      callback(solvedStamp);
      worker.terminate();
    };

    worker.onerror = function(e) {
      // console.error(`Hashcash Worker Error: ${e.message}`, e);
      worker.terminate();
    };

    // Start the worker.
    //console.log("Sending data to worker:", stampData);
    worker.postMessage(stampData);

  } catch (e) {
    console.error("CRITICAL: Failed to create Web Worker.", e);
    console.error("This can be due to a syntax error in the worker file, a Content Security Policy (CSP) issue, or the file not being served correctly.");
  }
};

// The Stamp object remains for data representation.
Hashcash.Stamp = function(version, bits, date, resource, extension, rand, counter = 0) {
  this.version = version;
  this.bits = bits;
  this.date = date;
  this.resource = resource;
  this.extension = extension;
  this.rand = rand;
  this.counter = Number(counter); // Ensure counter is a number
};

Hashcash.Stamp.parse = function(string) {
  const args = string.split(":");
  return new Hashcash.Stamp(...args);
};

Hashcash.Stamp.prototype.toString = function() {
  return [this.version, this.bits, this.date, this.resource, this.extension, this.rand, this.counter].join(":");
};

// Moved performance logging here to keep the Stamp object clean.
Hashcash.Stamp.prototype.logPerformance = function() {
  if (this.startedAt && this.endedAt) {
    const duration = this.endedAt - this.startedAt;
    const speed = Math.round(this.counter * 1000 / duration);
    console.debug(`Hashcash ${this.toString()} minted in ${duration.toFixed(0)}ms (${speed} hashes/sec)`);
  }
};

// Initialize on page load.
Hashcash.setup();
