import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="external-offer"
export default class extends Controller {
  static targets = ["submitButton", "form", "loadingIndicator"]

  connect() {
    this.originalSubmitText = this.submitButtonTarget.textContent
  }

  submit(event) {
    // Show loading state
    this.showLoading()
  }

  showLoading() {
    this.submitButtonTarget.disabled = true
    this.submitButtonTarget.textContent = "Creating..."

    if (this.hasLoadingIndicatorTarget) {
      this.loadingIndicatorTarget.classList.remove("hidden")
    }
  }

  hideLoading() {
    this.submitButtonTarget.disabled = false
    this.submitButtonTarget.textContent = this.originalSubmitText

    if (this.hasLoadingIndicatorTarget) {
      this.loadingIndicatorTarget.classList.add("hidden")
    }
  }

  clearForm() {
    this.formTarget.reset()
    this.hideLoading()
  }

  // Called when turbo:submit-end fires
  handleSubmitEnd(event) {
    this.hideLoading()

    // Check if the response contains a success flash message
    const response = event.detail.fetchResponse?.response
    if (response && response.ok) {
      // Wait a bit for the flash message to appear, then clear the form
      setTimeout(() => {
        // Check if there's a success message in the flash container
        const flashContainer = document.getElementById('flash-messages')
        if (flashContainer && flashContainer.textContent.includes('successfully')) {
          this.clearForm()
        }
      }, 100)
    }
  }

  // Alternative method that can be called directly via Turbo Streams
  handleSuccess() {
    this.clearForm()
  }
}
