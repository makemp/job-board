// app/javascript/controllers/voucher_controller.js
import { Controller } from "@hotwired/stimulus"
// Import the requestjs library for making fetch requests that handle Rails conventions (CSRF, Turbo Streams)
import { patch } from '@rails/request.js'

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
        const url = '/job_offer_forms'; // The collection path for your update action

        // Clear previous status messages and show "Applying..."
        this.statusTarget.textContent = "Applying...";
        this.statusTarget.style.color = 'grey'; // Optional: style the applying message

        // Prepare the data in the format expected by your Rails controller's strong parameters
        // { job_offer_form: { voucher_code: 'YOUR_CODE' } }
        const bodyPayload = {
            job_offer_form: {
                voucher_code: code
            }
        };



        try {
            // Send a PATCH request using @rails/request.js
            // It automatically handles the CSRF token and expects a Turbo Stream response
            const response = await patch(url, {
                body: JSON.stringify(bodyPayload), // Send data as JSON
                responseKind: 'turbo-stream' // Crucial: Tell request.js to expect and process a Turbo Stream
            });

            // If the request was successful (2xx status) and Turbo processed the stream:
            if (response.ok) {
                // Turbo Streams handled the UI update based on the controller's response.
                // We can clear the "Applying..." message. If the stream included an error
                // message in the status target's area, Turbo would have replaced it.
                // Only clear if it's still "Applying..." (meaning Turbo didn't replace it).
                if (this.statusTarget.textContent === "Applying...") {
                    this.statusTarget.textContent = ""; // Clear the status
                }
                console.log("Turbo Stream processed successfully.");
            } else {
                // Handle non-2xx responses that weren't Turbo Streams (e.g., 500 errors)
                // Note: 422 Unprocessable Entity with a Turbo Stream *should* be handled above by Turbo
                console.error("Request failed with status:", response.statusCode);
                this.statusTarget.textContent = 'The voucher is invalid or expired.';
                this.statusTarget.style.color = 'red';
            }
        } catch (error) {
            // Handle network errors or other issues during the fetch
            console.error("Error submitting voucher:", error);
            this.statusTarget.textContent = "Network error. Please check your connection.";
            this.statusTarget.style.color = 'red';
        }
    }
}