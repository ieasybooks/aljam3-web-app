import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="cloudflare-turnstile"
export default class extends Controller {
  connect() {
    if (window.turnstile && this.element.innerHTML.trim() === "") {
      window.turnstile.render(this.element)
    }
  }
}
