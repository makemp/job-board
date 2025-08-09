// app/javascript/controllers/searchable_select_controller.js

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="searchable-select"
export default class extends Controller {
  // Define the elements this controller will interact with
  static targets = ["search", "optionsContainer", "optionGroup", "option", "hiddenInput", "clearButton"]

  connect() {
    // Set the initial display value if a value is already selected
    this.updateDisplay()
  }

  // This function is called whenever the user types in the search box
  filter() {
    const query = this.searchTarget.value.toLowerCase()

    // Show/hide individual options based on the query
    this.optionTargets.forEach(el => {
      const text = el.textContent.toLowerCase()
      el.classList.toggle("hidden", !text.includes(query))
    })

    // Show/hide entire groups if all their options are hidden
    this.optionGroupTargets.forEach(group => {
      const hasVisibleOptions = group.querySelectorAll('[data-searchable-select-target="option"]:not(.hidden)').length > 0
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

    this.toggleOptions(false) // Hide the options
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

  // Toggles the visibility of the dropdown
  toggleOptions(forceState) {
    if (typeof forceState === "boolean") {
        this.optionsContainerTarget.classList.toggle("hidden", !forceState)
    } else {
        this.optionsContainerTarget.classList.toggle("hidden")
    }
  }
  
  // Hides dropdown if user clicks outside of the component
  hideOnBlur(event) {
    if (!this.element.contains(event.target)) {
        this.toggleOptions(false)
    }
  }
}