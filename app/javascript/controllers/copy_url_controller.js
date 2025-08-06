import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="copy-url"
export default class extends Controller {
  static values = { url: String }
  static targets = ["button"]

  copy(event) {
    event.preventDefault();
    const url = this.urlValue;
    const button = this.buttonTarget;
    navigator.clipboard.writeText(url).then(() => {
      // Swap icon to a checkmark for feedback
      const originalIcon = button.querySelector('svg');
      const originalIconClone = originalIcon.cloneNode(true);
      const checkIcon = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
      checkIcon.setAttribute('class', originalIcon.getAttribute('class'));
      checkIcon.setAttribute('fill', 'none');
      checkIcon.setAttribute('stroke', 'currentColor');
      checkIcon.setAttribute('stroke-width', '2');
      checkIcon.setAttribute('viewBox', '0 0 24 24');
      checkIcon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />';
      originalIcon.replaceWith(checkIcon);
      setTimeout(() => {
        checkIcon.replaceWith(originalIconClone);
      }, 1500);
    });
  }
}
