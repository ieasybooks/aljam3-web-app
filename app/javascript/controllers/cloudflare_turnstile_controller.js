import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="cloudflare-turnstile"
export default class extends Controller {
  static values = {
    delay: { type: Number, default: 100 },
  }

  connect() {
    setTimeout(() => {
      if (window.turnstile && this.element.innerHTML.trim() === "") {
        window.turnstile.render(this.element)
      }
    }, this.delayValue)
  }
}
