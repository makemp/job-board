// app/javascript/controllers/anti_bot_controller.js
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="anti-bot"
export default class extends Controller {
    static targets = ["hiddenField", "form"]
    static values = {
        seed: Number,
        multiplier: { type: Number, default: 7 },
        offset: { type: Number, default: 42 }
    }

    connect() {
        console.log("AntiBot controller connected.");
        this.calculateAndSetValue();

        // Find the form and add submit event listener
        const form = this.element.querySelector('form');
        if (form) {
            form.addEventListener('submit', (event) => {
                // Recalculate the token right before submission
                this.calculateAndSetValue();
                console.log("Token recalculated before form submission");
            });
        }
    }

    calculateAndSetValue() {
        // Generate a simple mathematical calculation to prevent basic bots
        // This uses a combination of timestamp, seed value, and mathematical operations
        const timestamp = Date.now();
        // ALWAYS use the seed passed from Rails view - don't fallback to random generation
        const seed = this.seedValue;

        // Simple calculation: (timestamp % 10000) * multiplier + seed + offset
        const calculation = ((timestamp % 10000) * this.multiplierValue) + seed + this.offsetValue;

        // Set the calculated value to the hidden field
        this.hiddenFieldTarget.value = calculation;

        // Store calculation details as data attributes for backend validation
        this.element.dataset.antiBotTimestamp = timestamp;
        this.element.dataset.antiBotSeed = seed;

        const form = this.element.querySelector('form');
        if (!form) return;

        let timestampFieldName = 'anti_bot_timestamp';
        const anyInput = form.querySelector('input[name*="["]');
        if (anyInput) {
            const modelNameMatch = anyInput.name.match(/^(.*?)\[/);
            if (modelNameMatch && modelNameMatch[1]) {
                timestampFieldName = `${modelNameMatch[1]}[anti_bot_timestamp]`;
            }
        }

        let timestampField = form.querySelector(`input[name="${timestampFieldName}"]`);
        if (!timestampField) {
            timestampField = document.createElement('input');
            timestampField.type = 'hidden';
            timestampField.name = timestampFieldName;
            form.appendChild(timestampField);
        }
        timestampField.value = timestamp;

        console.log("Anti-bot value calculated and set:", calculation);
        console.log("Using timestamp:", timestamp, "seed:", seed, "multiplier:", this.multiplierValue, "offset:", this.offsetValue);
    }

    // Method to recalculate if needed (e.g., if form is being resubmitted)
    recalculate() {
        this.calculateAndSetValue();
    }
}
