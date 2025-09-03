import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { offset: { type: Number, default: 20 } }

  scroll() {
    // Scroll to the top of this element with smooth behavior
    const targetPosition = this.element.offsetTop - this.offsetValue

    window.scrollTo({
      top: targetPosition,
      behavior: "smooth"
    })
  }
}
