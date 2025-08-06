// app/javascript/controllers/voucher_controller.js
import { Controller } from "@hotwired/stimulus"
// Import the requestjs library for making fetch requests that handle Rails conventions (CSRF, Turbo Streams)
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
    // Define targets for the input field and the status display area
    static targets = [ "codeInput", "status" ]

    // Action triggered when the "Apply voucher" button is clicked
    async apply(event) {
        // Prevent the default button behavior (though type="button" mostly handles this)
        event.preventDefault();

        // Get the voucher code entered by the user, trimming whitespace
        const code = this.codeInputTarget.value.trim();
        if (code === '') return;
        const url = '/job_offer_forms'; // Use the correct Rails PATCH route

        // Clear previous status messages and show "Applying..."
        this.statusTarget.textContent = "";
        this.statusTarget.style.color = 'grey'; // Optional: style the applying message

        // Prepare form data for Rails strong parameters
        const formData = new FormData();
        formData.append('job_offer_form[voucher_code]', code);

        try {
            // Send PATCH via fetch so we can manually process Turbo Stream
            const token = document.querySelector("meta[name='csrf-token']").content
            const response = await fetch(url, {
                method: 'PATCH',
                headers: {
                    'Accept': 'text/vnd.turbo-stream.html, text/html',
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': token
                },
                body: JSON.stringify({ job_offer_form: { voucher_code: code } })
            })
            if (!response.ok) {
                this.statusTarget.textContent = 'Voucher is invalid/expired!'
                this.statusTarget.style.color = 'red';
            }
            const html = await response.text()
            // Let Turbo render the returned turbo-streams
            Turbo.renderStreamMessage(html)
        } catch (error) {
            console.error("Error submitting voucher:", error)
            this.statusTarget.textContent = "Network error. Please check your connection.";
            this.statusTarget.style.color = 'red';
        }
    }
}
