import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "widget", "categoryField", "regionField", "preview"]
  static values = {
    currentCategory: String,
    currentRegion: String,
    createUrl: String
  }

  connect() {
    this.updatePreview()
    this.syncFiltersFromPage()
  }

  // Sync filters from the main page filters
  syncFiltersFromPage() {
    const categorySelect = document.querySelector('select[name="category"]')
    const regionSelect = document.querySelector('select[name="region"]') // This is the hidden select from the main page

    if (categorySelect && this.hasCategoryFieldTarget) {
      this.categoryFieldTarget.value = categorySelect.value || ""
      this.currentCategoryValue = categorySelect.value || ""
    }

    if (regionSelect && this.hasRegionFieldTarget) {
      // For the searchable region select, we need to update both the hidden select and the visible search input
      const regionValue = regionSelect.value || ""
      this.regionFieldTarget.value = regionValue
      this.currentRegionValue = regionValue

      // Also update the visible search input that users actually see
      const regionSearchInput = document.querySelector('input[name="region_search"]')
      if (regionSearchInput) {
        // Set the display value to match the selected region
        if (regionValue) {
          regionSearchInput.value = regionValue
        } else {
          regionSearchInput.value = ""
          regionSearchInput.placeholder = "Search regions..."
        }
      }
    }

    this.updatePreview()
  }

  // Update the preview text when filters change
  filterChanged() {
    this.updatePreview()
  }

  updatePreview() {
    if (!this.hasPreviewTarget) return

    const category = this.hasCategoryFieldTarget ? this.categoryFieldTarget.value : ""
    const region = this.hasRegionFieldTarget ? this.regionFieldTarget.value : ""

    let description = "all jobs"
    const parts = []

    if (category) {
      parts.push(`${category} jobs`)
    }

    if (region) {
      parts.push(`in ${region}`)
    }

    if (parts.length > 0) {
      description = parts.join(' ')
    }

    this.previewTarget.textContent = description
  }

  // Toggle the widget visibility
  toggle() {
    const widget = document.getElementById('job-alert-widget')
    if (widget) {
      widget.classList.toggle('hidden')
    }
  }

  // Show the widget
  show(event) {
    event.preventDefault()
    const widget = document.getElementById('job-alert-widget')
    if (widget) {
      widget.classList.remove('hidden')
      this.syncFiltersFromPage()
    }
  }

  // Reset filters to match current page filters (called by "Sync Filters" button)
  resetToCurrentFilters(event) {
    if (event) event.preventDefault()
    this.syncFiltersFromPage()
  }

  // Hide the widget
  hide(event) {
    if (event) event.preventDefault()
    const widget = document.getElementById('job-alert-widget')
    if (widget) {
      widget.classList.add('hidden')
    }
  }

  stopPropagation(event) {
    event.stopPropagation()
  }
}
