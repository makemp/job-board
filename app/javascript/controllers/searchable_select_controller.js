// app/javascript/controllers/searchable_select_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "search", "dropdown", "option"]
  static values = { placeholder: String }

  connect() {
    // Set initial search input text if a value is pre-selected
    const selectedOption = this.selectTarget.options[this.selectTarget.selectedIndex]
    if (selectedOption && selectedOption.value) {
      this.searchTarget.value = selectedOption.text
    }
    
    // Apply placeholder if provided
    if (this.hasPlaceholderValue) {
      this.searchTarget.placeholder = this.placeholderValue
    }
  }

  filterOptions(event) {
    const searchTerm = event.target.value.toLowerCase()
    const groupHeaders = this.dropdownTarget.querySelectorAll('.bg-gray-100')
    let visibleGroups = new Set()

    this.optionTargets.forEach(option => {
      // Always show the "All Regions" option
      if (option.dataset.alwaysVisible === 'true') {
        option.style.display = 'block'
        return
      }
      
      const text = option.textContent.toLowerCase().trim()
      const isVisible = text.includes(searchTerm)
      option.style.display = isVisible ? 'block' : 'none'

      if (isVisible && searchTerm !== '') {
        // Find the group header before this option
        let prevElement = option.previousElementSibling
        while (prevElement && !prevElement.classList.contains('bg-gray-100')) {
          prevElement = prevElement.previousElementSibling
        }
        if (prevElement) {
          visibleGroups.add(prevElement)
        }
      }
    })

    // Show/hide group headers
    groupHeaders.forEach(header => {
      const shouldShow = searchTerm === '' || visibleGroups.has(header)
      header.style.display = shouldShow ? 'block' : 'none'
    })

    this.showDropdown()
  }

  selectOption(event) {
    event.preventDefault()
    const value = event.currentTarget.dataset.value
    const text = event.currentTarget.textContent.trim()

    this.selectTarget.value = value
    this.searchTarget.value = text

    this.updateVisualSelection(event.currentTarget)
    this.hideDropdown()
    this.selectTarget.dispatchEvent(new Event('change', { bubbles: true }))
  }

  selectAllRegions(event) {
    event.preventDefault()
    this.searchTarget.value = '' // Clear visible input
    this.selectTarget.value = '' // Set underlying select to blank

    this.filterOptions({ target: { value: '' } }) // Reset filter to show all
    this.updateVisualSelection(event.currentTarget)
    this.hideDropdown()
    this.selectTarget.dispatchEvent(new Event('change', { bubbles: true }))
  }
  
  updateVisualSelection(selectedElement) {
    this.optionTargets.forEach(opt => opt.classList.remove('bg-amber-200'))
    selectedElement.classList.add('bg-amber-200')
  }

  showDropdown() {
    this.dropdownTarget.classList.remove('hidden')
  }

  hideDropdown() {
    this.dropdownTarget.classList.add('hidden')
  }

  hideDropdownDelayed() {
    setTimeout(() => this.hideDropdown(), 200)
  }

  handleKeydown(event) {
    const visibleOptions = this.optionTargets.filter(
      option => option.style.display !== 'none'
    )
    if (visibleOptions.length === 0) return

    const activeClass = 'bg-amber-100' // Use a hover/active class
    const currentActive = this.dropdownTarget.querySelector(`.${activeClass}`)
    let currentIndex = currentActive ? visibleOptions.indexOf(currentActive) : -1

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        currentIndex = (currentIndex + 1) % visibleOptions.length
        this.highlightOption(visibleOptions, currentIndex, activeClass)
        break
      case 'ArrowUp':
        event.preventDefault()
        currentIndex = (currentIndex - 1 + visibleOptions.length) % visibleOptions.length
        this.highlightOption(visibleOptions, currentIndex, activeClass)
        break
      case 'Enter':
        event.preventDefault()
        if (currentIndex > -1) {
          // Use mousedown to trigger the action correctly
          visibleOptions[currentIndex].dispatchEvent(new MouseEvent('mousedown', { bubbles: true }))
        } else if (visibleOptions.length > 0) {
          // If nothing is highlighted, select the first visible option
          visibleOptions[0].dispatchEvent(new MouseEvent('mousedown', { bubbles: true }))
        }
        break
      case 'Escape':
        this.hideDropdown()
        break
    }
  }

  highlightOption(options, index, activeClass) {
    options.forEach(option => option.classList.remove(activeClass))
    if (index >= 0 && index < options.length) {
      options[index].classList.add(activeClass)
      options[index].scrollIntoView({ block: 'nearest' })
    }
  }
}