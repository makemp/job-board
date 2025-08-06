import { Controller } from "@hotwired/stimulus"

// Controls tab switching for various UI elements
export default class extends Controller {
  static targets = ["tab", "pane"]

  connect() {
    const defaultTab = this.data.get("initialTab") || (this.hasTabTarget ? this.tabTargets[0].dataset.tabName : null)
    if (defaultTab) {
      this.showTab(defaultTab)
    }
  }

  show(event) {
    const tabName = event.currentTarget.dataset.tabName
    if (tabName) {
      this.showTab(tabName)
    }
  }

  showFromSelect(event) {
    const tabName = event.target.value
    if (tabName) {
      this.showTab(tabName)
    }
  }

  showTab(name) {
    // Update tabs
    this.tabTargets.forEach(tab => {
      const isActive = tab.dataset.tabName === name
      tab.classList.toggle('border-amber-900', isActive) // Example for active tab styling
      tab.classList.toggle('border-transparent', !isActive)
      // Add more sophisticated active/inactive styling as needed
      if (tab.tagName === 'BUTTON') {
        tab.classList.toggle('bg-amber-100', isActive)
        tab.classList.toggle('text-amber-800', isActive)
        tab.classList.toggle('bg-gray-100', !isActive)
      }
    })

    // Update panes
    this.paneTargets.forEach(pane => {
      pane.classList.toggle('hidden', pane.dataset.tabName !== name)
    })

    // Update mobile select if it exists
    const mobileSelect = this.element.querySelector('#mobile-tab-select');
    if (mobileSelect && mobileSelect.value !== name) {
      mobileSelect.value = name;
    }
  }
}
