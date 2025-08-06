// app/javascript/controllers/toggle_fields_controller.js
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle-fields"
export default class extends Controller {
    // Define the elements we need to interact with
    static targets = ["formInput", "linkInput", "radio"]

    connect() {
        // This runs as soon as the controller is connected to the DOM
        console.log("ToggleFields controller connected.");
        this.toggle(); // Call the toggle method on page load
    }

    toggle() {
        // Find the currently checked radio button from the ones we are targeting
        const checkedRadio = this.radioTargets.find(radio => radio.checked);
        if (!checkedRadio) return; // Exit if nothing is checked

        const selectedValue = checkedRadio.value;

        // Check which radio is selected.
        // Assumes your JobOffer::APPLICATION_TYPES are "Form" and "Link"
        const showForm = selectedValue === "Form";

        // Toggle visibility on the PARENT element of the inputs
        this.formInputTarget.parentElement.classList.toggle('hidden', !showForm);
        this.linkInputTarget.parentElement.classList.toggle('hidden', showForm);

        // CRUCIAL: Disable the input that is hidden
        this.formInputTarget.disabled = !showForm;
        this.linkInputTarget.disabled = showForm;
    }
}