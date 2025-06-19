import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="cloudflare-turnstile"
export default class extends Controller {
  connect() {
    if (document.querySelector(".cf-turnstile") && window.turnstile) {
      window.turnstile.render(".cf-turnstile", { language: document.documentElement.lang });
    }
  }
}
