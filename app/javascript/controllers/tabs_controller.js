import { Controller } from "@hotwired/stimulus"

// Controls tab switching between login methods
export default class extends Controller {
  static targets = ["tab", "pane"]

  connect() {
    const defaultTab = this.data.get("initialTab") || this.tabTargets[0].dataset.tabName
    this.showTab(defaultTab)
  }

  show(event) {
    const name = event.params && event.params.name ? event.params.name : event.currentTarget.dataset.tabName
    this.showTab(name)
  }

  showTab(name) {
    this.tabTargets.forEach(tab => {
      const isActive = tab.dataset.tabName === name
      tab.classList.toggle('border-amber-900', isActive)
      tab.classList.toggle('border-transparent', !isActive)
    })
    this.paneTargets.forEach(pane => {
      pane.classList.toggle('hidden', pane.dataset.tabName !== name)
    })
  }
}

