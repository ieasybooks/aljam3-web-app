import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ruby-ui--dismiss-alert"
export default class extends Controller {
  dismiss() {
    this.element.remove()
  }
}
