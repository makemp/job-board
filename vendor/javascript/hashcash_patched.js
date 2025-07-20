// A modern, secure, and performant implementation of client-side Hashcash.
// NOTE: This is useless without mandatory server-side validation.

const Hashcash = function(input) {
  console.log("Hashcash constructor called for input:", input);
  const options = JSON.parse(input.getAttribute("data-hashcash"));
  Hashcash.disableParentForm(input, options);
  input.dispatchEvent(new CustomEvent("hashcash:mint", { bubbles: true }));

  // Keep track of the start time for performance measurement.
  const startedAt = performance.now();

  Hashcash.mint(options.resource, options, function(stamp) {
    console.log("Callback received from worker with solved stamp:", stamp);
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
 * This function is designed to be called multiple times, e.g., on page load and after
 * dynamic content changes (like Turbo Drive visits).
 */
Hashcash.initializeNewInputs = function() {
  // Find all inputs that have the attribute but have not been initialized.
  const inputs = document.querySelectorAll("input[data-hashcash]:not([data-hashcash-initialized])");

  if (inputs.length > 0) {
    console.log(`Found ${inputs.length} new hashcash input(s). Initializing.`);
  }

  inputs.forEach(input => {
    // Mark as initialized to prevent running twice on the same element.
    input.setAttribute("data-hashcash-initialized", "true");
    new Hashcash(input);
  });
};


/**
 * Sets up the initial listeners to detect and initialize hashcash inputs,
 * including those added dynamically by frameworks like Turbo.
 */
Hashcash.setup = function() {
  console.log("1. Hashcash.setup() called. Setting up listeners for dynamic content.");

  // Listener for Turbo Drive page loads. This is the primary trigger for Turbo apps.
  document.addEventListener("turbo:load", function() {
    console.log("Event: 'turbo:load' detected. Scanning for hashcash inputs.");
    Hashcash.initializeNewInputs();
  });

  // Fallback for initial page load if Turbo is not present or loads late.
  document.addEventListener("DOMContentLoaded", function() {
    console.log("Event: 'DOMContentLoaded' detected. Scanning for hashcash inputs.");
    Hashcash.initializeNewInputs();
  });

  // Use a MutationObserver to catch any other dynamic additions to the page.
  // This is a robust way to handle content added by any framework.
  const observer = new MutationObserver((mutationsList) => {
    for (const mutation of mutationsList) {
      if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
        let needsScan = false;
        mutation.addedNodes.forEach(node => {
          if (node.nodeType === Node.ELEMENT_NODE) {
            if (node.matches("input[data-hashcash]") || node.querySelector("input[data-hashcash]")) {
              needsScan = true;
            }
          }
        });
        if(needsScan) {
          console.log("DOM mutation detected. Rescanning for hashcash inputs.");
          Hashcash.initializeNewInputs();
        }
      }
    }
  });

  // Start observing the body for added/removed nodes.
  observer.observe(document.body, { childList: true, subtree: true });

  // Perform an initial scan in case the script loads after the DOM is ready.
  Hashcash.initializeNewInputs();
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
  bits: 20, // A reasonable default difficulty. Adjust as needed.
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
  console.log("Minting called. Attempting to create worker from path:", options.worker_path || Hashcash.default.worker_path);

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
      console.log("Message received from worker:", e.data);
      const solvedStamp = Hashcash.Stamp.parse(e.data);
      callback(solvedStamp);
      worker.terminate();
    };

    worker.onerror = function(e) {
      console.error(`Hashcash Worker Error: ${e.message}`, e);
      worker.terminate();
    };

    // Start the worker.
    console.log("Sending data to worker:", stampData);
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
