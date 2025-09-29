import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pending-offer-actions"
export default class extends Controller {
  static targets = ["form"]

  connect() {
    console.log("Pending offer actions controller connected")
  }

  submitStart(event) {
    const form = event.currentTarget
    const button = form.querySelector('button[type="submit"]')
    const card = form.closest('[id^="external_job_offer_"]')
    const action = button.textContent.trim().toLowerCase()

    this.setLoadingState(button, `${action.charAt(0).toUpperCase() + action.slice(1)}ing...`)
    this.addCardProcessingState(card, action)
  }

  setLoadingState(button, text) {
    // Disable all buttons in the card to prevent multiple clicks
    const card = button.closest('[id^="external_job_offer_"]')
    if (card) {
      const allButtons = card.querySelectorAll('button, input[type="submit"]')
      allButtons.forEach(btn => btn.disabled = true)
    }

    const originalContent = button.innerHTML
    button.dataset.originalContent = originalContent
    button.innerHTML = `
      <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white inline" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      ${text}
    `
  }

  addCardProcessingState(card, action) {
    if (!card) return

    // Add visual feedback to the card
    card.style.opacity = "0.7"
    card.style.transition = "all 0.3s ease"

    // Add a subtle border color based on action
    if (action.includes("approve")) {
      card.style.borderColor = "#10b981" // green
      card.style.backgroundColor = "#f0fdf4" // light green
    } else if (action.includes("hide")) {
      card.style.borderColor = "#ef4444" // red
      card.style.backgroundColor = "#fef2f2" // light red
    }

    // Add a processing indicator
    const indicator = document.createElement('div')
    indicator.className = 'absolute top-2 right-2 w-3 h-3 rounded-full animate-pulse'
    indicator.style.backgroundColor = action.includes("approve") ? "#10b981" : "#ef4444"

    if (!card.style.position) {
      card.style.position = "relative"
    }
    card.appendChild(indicator)
  }
}
