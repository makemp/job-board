import { Controller } from "@hotwired/stimulus"

// Controls tab switching for various UI elements
export default class extends Controller {
  static targets = ["tab", "pane"]

  connect() {
    // Check for hash in URL first
    const hashTab = this.getTabFromHash()
    const defaultTab = hashTab || this.data.get("initialTab") || (this.hasTabTarget ? this.tabTargets[0].dataset.tabName : null)

    if (defaultTab) {
      this.showTab(defaultTab, false) // Don't update hash on initial load if hash was already present
    }

    // Listen for hash changes
    window.addEventListener('hashchange', () => {
      const tabFromHash = this.getTabFromHash()
      if (tabFromHash && this.isValidTab(tabFromHash)) {
        this.showTab(tabFromHash, false)
      }
    })
  }

  disconnect() {
    window.removeEventListener('hashchange', this.handleHashChange)
  }

  show(event) {
    const tabName = event.currentTarget.dataset.tabName
    if (tabName) {
      this.showTab(tabName, true)
    }
  }

  showFromSelect(event) {
    const tabName = event.target.value
    if (tabName) {
      this.showTab(tabName, true)
    }
  }

  showTab(name, updateHash = true) {
    // Update URL hash if requested
    if (updateHash) {
      window.history.replaceState(null, null, `#${name}`)
    }

    // Update tabs
    this.tabTargets.forEach(tab => {
      const isActive = tab.dataset.tabName === name
      tab.classList.toggle('active', isActive)
      tab.classList.toggle('border-blue-500', isActive)
      tab.classList.toggle('text-blue-600', isActive)
      tab.classList.toggle('border-transparent', !isActive)
      tab.classList.toggle('text-gray-500', !isActive)

      // Legacy styling support
      tab.classList.toggle('border-amber-900', isActive)
      tab.classList.toggle('bg-amber-100', isActive && tab.tagName === 'BUTTON')
      tab.classList.toggle('text-amber-800', isActive && tab.tagName === 'BUTTON')
      tab.classList.toggle('bg-gray-100', !isActive && tab.tagName === 'BUTTON')
    })

    // Update panes
    this.paneTargets.forEach(pane => {
      const isActive = pane.dataset.tabName === name
      pane.classList.toggle('hidden', !isActive)
      pane.classList.toggle('active', isActive)
    })

    // Update mobile select if it exists
    const mobileSelect = this.element.querySelector('#mobile-tab-select');
    if (mobileSelect && mobileSelect.value !== name) {
      mobileSelect.value = name;
    }
  }

  getTabFromHash() {
    const hash = window.location.hash.substring(1) // Remove the # character
    return hash || null
  }

  isValidTab(tabName) {
    return this.tabTargets.some(tab => tab.dataset.tabName === tabName)
  }
}
