import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
    connect() {
        // console.log("Modal controller connected", this.element);
        // Ensure the modal is focusable, or the first focusable element inside gets focus
        // This helps with keyboard navigation and screen readers
        this.element.focus()
    }

    disconnect() {
        // console.log("Modal controller disconnected");
    }

    /**
     * Closes the modal by finding its parent Turbo Frame and clearing its content.
     * This leaves the frame tag available for future replacements.
     */
    close() {
        // console.log("Closing modal");
        const frame = this.element.closest('turbo-frame'); // Find the parent turbo-frame
        if (frame) {
            // Clear the content of the frame. This removes the modal visually
            // but leaves the <turbo-frame> tag itself.
            frame.innerHTML = '';
        } else {
            // Fallback if somehow it's not in a frame (though it should be)
            this.element.remove();
        }
    }

    /**
     * Handles the Escape key press to close the modal.
     */
    handleKeyup(event) {
        if (event.key === "Escape") {
            this.close()
        }
    }
}