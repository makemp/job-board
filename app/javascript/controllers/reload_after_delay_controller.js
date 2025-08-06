import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Connects to data-controller="reload-after-delay"
export default class extends Controller {
  static values = { delay: Number, url: String }

  connect() {
    setTimeout(() => {
      if (this.urlValue) {
        Turbo.visit(this.urlValue)
      } else {
        Turbo.visit(window.location.href)
      }
    }, this.delayValue || 10000)
  }
}

