// app/javascript/controllers/searchable_select_simple_controller.js

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="searchable-select-simple"
export default class extends Controller {
  // Define the elements this controller will interact with
  static targets = ["search", "optionsContainer", "optionGroup", "option", "hiddenInput", "clearButton"]

  connect() {
    // Set the initial display value if a value is already selected
    this.updateDisplay()
    // Add focus and blur event listeners to the search input
    this.searchTarget.addEventListener('focus', this.onFocus.bind(this))
    this.searchTarget.addEventListener('blur', this.onBlur.bind(this))
  }

  disconnect() {
    // Clean up event listeners when controller disconnects
    this.searchTarget.removeEventListener('focus', this.onFocus.bind(this))
    this.searchTarget.removeEventListener('blur', this.onBlur.bind(this))
  }

  // Handle focus on the search input
  onFocus() {
    // Show options when the search input is focused
    this.toggleOptions(false) // ensure dropdown is shown when focused
  }

  // Handle blur on the search input
  onBlur(event) {
    // Add a small delay to allow click events to complete first
    setTimeout(() => {
      this.hideOptions()
    }, 150)
  }

  // This function is called whenever the user types in the search box
  filter() {
    const query = this.searchTarget.value.toLowerCase()

    // Show the options container when typing
    this.optionsContainerTarget.classList.remove('hidden')

    // Show/hide individual options based on the query
    this.optionTargets.forEach(el => {
      const text = el.textContent.toLowerCase()
      el.classList.toggle("hidden", !text.includes(query))
    })

    // Show/hide entire groups if all their options are hidden
    this.optionGroupTargets.forEach(group => {
      const hasVisibleOptions = group.querySelectorAll('[data-searchable-select-simple-target="option"]:not(.hidden)').length > 0
      group.classList.toggle("hidden", !hasVisibleOptions)
    })
  }

  // This function runs when a user clicks an option
  selectOption(event) {
    event.preventDefault()
    const selectedOption = event.currentTarget

    // Update the hidden input that gets submitted with the form
    this.hiddenInputTarget.value = selectedOption.dataset.value

    // Update the visible search box to show the selected text
    this.searchTarget.value = selectedOption.textContent.trim()

    // Hide the options after selection
    this.hideOptions()

    // Focus back on the search input to maintain user's context
    this.searchTarget.focus()
  }

  // Sets the initial text in the search box if a value is pre-selected
  updateDisplay() {
    const selectedValue = this.hiddenInputTarget.value
    if (selectedValue) {
      const selectedOption = this.optionTargets.find(opt => opt.dataset.value === selectedValue)
      if (selectedOption) {
        this.searchTarget.value = selectedOption.textContent.trim()
      }
    }
  }

  // Toggle the options dropdown visibility
  toggleOptions(event) {
    if (typeof event === 'boolean') {
      this.optionsContainerTarget.classList.toggle('hidden', event)
    } else {
      this.optionsContainerTarget.classList.toggle('hidden')
    }
  }

  // Hide the options dropdown
  hideOptions() {
    this.optionsContainerTarget.classList.add('hidden')
  }

  // Hide the dropdown when clicking outside
  hideOnBlur(event) {
    if (!this.element.contains(event.target)) {
      this.hideOptions()
    }
  }
}
