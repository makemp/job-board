import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Connects to data-controller="reload-after-delay"
export default class extends Controller {
  static values = { delay: Number, url: String, maxReloads: { type: Number, default: 3 } }

  connect() {
    const key = `reloadCount_${window.location.pathname}`;
    const reloadCount = parseInt(sessionStorage.getItem(key) || "0");

    if (reloadCount >= this.maxReloadsValue) {
      sessionStorage.removeItem(key);
      Turbo.visit("/");
      return;
    }

    sessionStorage.setItem(key, reloadCount + 1);

    setTimeout(() => {
      if (this.urlValue) {
        Turbo.visit(this.urlValue)
      } else {
        Turbo.visit(window.location.href)
      }
    }, this.delayValue || 10000)
  }
}
