import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mobile-menu"
export default class extends Controller {
  static targets = ["menu", "hamburgerIcon", "closeIcon"]

  connect() {
    // Ensure menu is initially hidden
    this.hideMenu()
  }

  toggle() {
    if (this.menuTarget.classList.contains('hidden')) {
      this.showMenu()
    } else {
      this.hideMenu()
    }
  }

  showMenu() {
    this.menuTarget.classList.remove('hidden')
    this.hamburgerIconTarget.classList.add('hidden')
    this.closeIconTarget.classList.remove('hidden')
  }

  hideMenu() {
    this.menuTarget.classList.add('hidden')
    this.hamburgerIconTarget.classList.remove('hidden')
    this.closeIconTarget.classList.add('hidden')
  }
}
