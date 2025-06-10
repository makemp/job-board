import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="logo-preview"
export default class extends Controller {
  static targets = ["input", "output"]

  show() {
    if (this.inputTarget.files.length > 0) {
      const file = this.inputTarget.files[0]
      const url = URL.createObjectURL(file)

      // Set the src of our output <img> tag (as before)
      this.outputTarget.src = url

      // --- NEW ---
      // Make the image tag visible by removing the 'hidden' class.
      this.outputTarget.classList.remove('hidden')
    }
  }
}