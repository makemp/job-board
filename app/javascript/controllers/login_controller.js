import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  connect() {
    // Initialize Hashcash for any existing forms
    this.initializeHashcash()

    // Listen for turbo frame updates
    this.element.addEventListener('turbo:frame-load', this.handleFrameLoad.bind(this))
  }

  disconnect() {
    this.element.removeEventListener('turbo:frame-load', this.handleFrameLoad.bind(this))
  }

  handleFrameLoad(event) {
    // Initialize Hashcash when new content is loaded into the frame
    setTimeout(() => this.initializeHashcash(), 50)
  }

  // Initialize Hashcash for all forms with hashcash inputs
  initializeHashcash() {
    const hashcashInputs = this.element.querySelectorAll('input[data-hashcash]')
    hashcashInputs.forEach(input => {
      if (window.Hashcash && !input.dataset.hashcashInitialized) {
        try {
          new Hashcash(input)
          input.dataset.hashcashInitialized = 'true'
        } catch (error) {
          console.warn('Hashcash initialization failed:', error)
          // Fallback: ensure the form is still usable
          const form = input.form
          if (form) {
            form.querySelectorAll("[type=submit]").forEach(function(submit) {
              submit.disabled = false
            })
          }
        }
      }
    })
  }
}
