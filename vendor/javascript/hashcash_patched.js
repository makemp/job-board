// A modern, secure, and performant implementation of client-side Hashcash.
// NOTE: This is useless without mandatory server-side validation.

const Hashcash = function(input) {
  const options = JSON.parse(input.getAttribute("data-hashcash"));
  Hashcash.disableParentForm(input, options);
  input.dispatchEvent(new CustomEvent("hashcash:mint", { bubbles: true }));

  // Keep track of the start time for performance measurement.
  const startedAt = performance.now();

  Hashcash.mint(options.resource, options, function(stamp) {
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

Hashcash.setup = function() {
  if (document.readyState !== "loading") {
    // Note: The original implementation selected by ID, this selects by attribute for more flexibility.
    const input = document.querySelector("input[data-hashcash]");
    if (input) {
      new Hashcash(input);
    }
  } else {
    document.addEventListener("DOMContentLoaded", Hashcash.setup);
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
  const workerPath = options.worker_path || Hashcash.default.worker_path;
  const worker = new Worker(workerPath);

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
    const solvedStamp = Hashcash.Stamp.parse(e.data);
    callback(solvedStamp);
    worker.terminate();
  };

  worker.onerror = function(e) {
    console.error(`Hashcash Worker Error: ${e.message}`);
    // Optional: Re-enable the form on error.
    // const input = document.querySelector("input[data-hashcash]");
    // if (input) Hashcash.enableParentForm(input, options);
    worker.terminate();
  };

  // Start the worker.
  worker.postMessage(stampData);
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