import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "search", "dropdown", "option"]
  static values = { placeholder: String }

  connect() {
    this.createSearchableDropdown()
  }

  createSearchableDropdown() {
    // Hide the original select
    this.selectTarget.style.display = 'none'

    // Create wrapper
    const wrapper = document.createElement('div')
    wrapper.className = 'relative'

    // Create search input
    const searchInput = document.createElement('input')
    searchInput.type = 'text'
    searchInput.placeholder = this.placeholderValue || 'Search...'
    searchInput.className = this.selectTarget.className
    searchInput.setAttribute('data-searchable-select-target', 'search')
    searchInput.addEventListener('input', this.filterOptions.bind(this))
    searchInput.addEventListener('focus', this.showDropdown.bind(this))
    searchInput.addEventListener('blur', this.hideDropdownDelayed.bind(this))
    searchInput.addEventListener('keydown', this.handleKeydown.bind(this))

    // Create dropdown
    const dropdown = document.createElement('div')
    dropdown.className = 'absolute z-50 w-full mt-1 bg-white border border-gray-300 rounded-md shadow-lg max-h-60 overflow-auto hidden'
    dropdown.setAttribute('data-searchable-select-target', 'dropdown')

    // Populate dropdown with options
    this.populateDropdown(dropdown)

    // Insert wrapper before select
    this.selectTarget.parentNode.insertBefore(wrapper, this.selectTarget)
    wrapper.appendChild(searchInput)
    wrapper.appendChild(dropdown)
    wrapper.appendChild(this.selectTarget)

    // Set initial value
    const selectedOption = this.selectTarget.options[this.selectTarget.selectedIndex]
    if (selectedOption && selectedOption.value) {
      searchInput.value = selectedOption.text
    }
  }

  populateDropdown(dropdown) {
    // Add "All Regions" option at the top
    const allRegionsOption = document.createElement('div')
    allRegionsOption.className = 'px-3 py-2 cursor-pointer hover:bg-amber-100 text-gray-900 font-medium border-b border-gray-200'
    allRegionsOption.textContent = 'All Regions'
    allRegionsOption.setAttribute('data-value', '')
    allRegionsOption.setAttribute('data-searchable-select-target', 'option')
    allRegionsOption.setAttribute('data-always-visible', 'true')
    allRegionsOption.addEventListener('mousedown', this.selectAllRegions.bind(this))
    dropdown.appendChild(allRegionsOption)

    let currentGroup = null

    Array.from(this.selectTarget.options).forEach(option => {
      if (option.value === '') return // Skip blank option

      const parentGroup = option.parentNode.tagName === 'OPTGROUP' ? option.parentNode : null

      // Add group header if needed
      if (parentGroup && parentGroup !== currentGroup) {
        const groupHeader = document.createElement('div')
        groupHeader.className = 'px-3 py-2 text-sm font-semibold text-gray-700 bg-gray-100 border-b'
        groupHeader.textContent = parentGroup.label
        dropdown.appendChild(groupHeader)
        currentGroup = parentGroup
      }

      // Add option
      const optionElement = document.createElement('div')
      optionElement.className = 'px-3 py-2 cursor-pointer hover:bg-amber-100 text-gray-900'
      optionElement.textContent = option.text
      optionElement.setAttribute('data-value', option.value)
      optionElement.setAttribute('data-searchable-select-target', 'option')
      optionElement.addEventListener('mousedown', this.selectOption.bind(this))

      if (option.selected) {
        optionElement.classList.add('bg-amber-200')
      }

      dropdown.appendChild(optionElement)
    })
  }

  filterOptions(event) {
    const searchTerm = event.target.value.toLowerCase()
    const options = this.dropdownTarget.querySelectorAll('[data-searchable-select-target="option"]')
    const groupHeaders = this.dropdownTarget.querySelectorAll('.bg-gray-100')

    let visibleGroups = new Set()

    options.forEach(option => {
      // Always show the "All Regions" option
      if (option.getAttribute('data-always-visible') === 'true') {
        option.style.display = 'block'
        return
      }

      // If search term is empty, show all other options
      if (searchTerm === '') {
        option.style.display = 'block'
      } else {
        const text = option.textContent.toLowerCase()
        const isVisible = text.includes(searchTerm)

        if (isVisible) {
          option.style.display = 'block'
          // Find the group header before this option
          let prevElement = option.previousElementSibling
          while (prevElement && !prevElement.classList.contains('bg-gray-100')) {
            prevElement = prevElement.previousElementSibling
          }
          if (prevElement) {
            visibleGroups.add(prevElement)
          }
        } else {
          option.style.display = 'none'
        }
      }
    })

    // Show/hide group headers based on whether they have visible options
    if (searchTerm === '') {
      groupHeaders.forEach(header => {
        header.style.display = 'block'
      })
    } else {
      groupHeaders.forEach(header => {
        header.style.display = visibleGroups.has(header) ? 'block' : 'none'
      })
    }

    this.showDropdown()
  }

  selectOption(event) {
    const value = event.target.getAttribute('data-value')
    const text = event.target.textContent

    // Update select
    this.selectTarget.value = value

    // Update search input
    this.searchTarget.value = text

    // Update visual selection
    this.optionTargets.forEach(option => {
      option.classList.remove('bg-amber-200')
    })
    event.target.classList.add('bg-amber-200')

    // Hide dropdown
    this.hideDropdown()

    // Trigger change event on the original select
    this.selectTarget.dispatchEvent(new Event('change', { bubbles: true }))
  }

  selectAllRegions(event) {
    // Clear the search input
    this.searchTarget.value = ''

    // Update select to empty value (All Regions)
    this.selectTarget.value = ''

    // Update visual selection
    this.optionTargets.forEach(option => {
      option.classList.remove('bg-amber-200')
    })
    event.target.classList.add('bg-amber-200')

    // Show all options again
    const options = this.dropdownTarget.querySelectorAll('[data-searchable-select-target="option"]:not([data-always-visible])')
    const groupHeaders = this.dropdownTarget.querySelectorAll('.bg-gray-100')

    options.forEach(option => {
      option.style.display = 'block'
    })
    groupHeaders.forEach(header => {
      header.style.display = 'block'
    })

    // Hide dropdown
    this.hideDropdown()

    // Trigger change event on the original select
    this.selectTarget.dispatchEvent(new Event('change', { bubbles: true }))
  }

  showDropdown() {
    this.dropdownTarget.classList.remove('hidden')
  }

  hideDropdown() {
    this.dropdownTarget.classList.add('hidden')
  }

  hideDropdownDelayed() {
    // Delay hiding to allow option clicks to register
    setTimeout(() => {
      this.hideDropdown()
    }, 200)
  }

  handleKeydown(event) {
    const options = Array.from(this.dropdownTarget.querySelectorAll('[data-searchable-select-target="option"]'))
      .filter(option => option.style.display !== 'none')

    if (options.length === 0) return

    const currentSelected = this.dropdownTarget.querySelector('.bg-blue-100')
    let currentIndex = currentSelected ? options.indexOf(currentSelected) : -1

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        currentIndex = Math.min(currentIndex + 1, options.length - 1)
        this.highlightOption(options, currentIndex)
        break
      case 'ArrowUp':
        event.preventDefault()
        currentIndex = Math.max(currentIndex - 1, 0)
        this.highlightOption(options, currentIndex)
        break
      case 'Enter':
        event.preventDefault()
        if (currentIndex >= 0) {
          options[currentIndex].click()
        }
        break
      case 'Escape':
        this.hideDropdown()
        break
    }
  }

  highlightOption(options, index) {
    options.forEach(option => option.classList.remove('bg-blue-100'))
    if (index >= 0 && index < options.length) {
      options[index].classList.add('bg-blue-100')
      options[index].scrollIntoView({ block: 'nearest' })
    }
  }
}
