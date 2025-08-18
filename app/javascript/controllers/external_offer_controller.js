import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="external-offer"
export default class extends Controller {
  static targets = ["submitButton", "form", "loadingIndicator", "urlField", "urlStatus"]

  connect() {
    this.originalSubmitText = this.submitButtonTarget.textContent
    this.checkTimeout = null
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
    this.clearUrlStatus()
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

  // Check URL when user types or pastes
  checkUrl(event) {
    const url = event.target.value.trim()

    // Clear previous timeout
    if (this.checkTimeout) {
      clearTimeout(this.checkTimeout)
    }

    // Clear status if URL is empty
    if (!url) {
      this.clearUrlStatus()
      return
    }

    // Show checking status immediately
    this.showCheckingStatus()

    // Debounce the actual check by 500ms
    this.checkTimeout = setTimeout(() => {
      this.performUrlCheck(url)
    }, 500)
  }

  async performUrlCheck(url) {
    try {
      const response = await fetch('/amdg/external_offers/check_url', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({ url: url })
      })

      const data = await response.json()

      if (data.exists) {
        this.showUrlExistsWarning(data.message, data.offer)
      } else {
        this.showUrlAvailable()
      }
    } catch (error) {
      console.error('URL check error:', error)
      this.clearUrlStatus()
    }
  }

  showCheckingStatus() {
    if (this.hasUrlStatusTarget) {
      this.urlStatusTarget.innerHTML = `
        <div class="flex items-center text-blue-600 text-sm mt-2">
          <svg class="animate-spin -ml-1 mr-2 h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          Checking URL...
        </div>
      `
    }
  }

  showUrlExistsWarning(message, offer) {
    if (this.hasUrlStatusTarget) {
      this.urlStatusTarget.innerHTML = `
        <div class="bg-yellow-50 border border-yellow-200 rounded-md p-3 mt-2">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg class="h-5 w-5 text-yellow-400" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
              </svg>
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-yellow-800">URL Already Exists</h3>
              <div class="mt-2 text-sm text-yellow-700">
                <p>${message}</p>
                <p class="mt-1 text-xs">Created: ${offer.created_at}</p>
              </div>
            </div>
          </div>
        </div>
      `
    }
  }

  showUrlAvailable() {
    if (this.hasUrlStatusTarget) {
      this.urlStatusTarget.innerHTML = `
        <div class="flex items-center text-green-600 text-sm mt-2">
          <svg class="mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
          </svg>
          URL is available
        </div>
      `
    }
  }

  clearUrlStatus() {
    if (this.hasUrlStatusTarget) {
      this.urlStatusTarget.innerHTML = ""
    }
  }

  // Alternative method that can be called directly via Turbo Streams
  handleSuccess() {
    this.clearForm()
  }
}
