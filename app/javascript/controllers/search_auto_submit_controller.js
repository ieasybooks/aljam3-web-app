import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search-auto-submit"
export default class extends Controller {
  static targets = ["input"]
  static values = { delay: { type: Number, default: 150 } }

  connect() {
    this.timeout = null
  }

  submit() {
    if (this.inputTarget.value.length > 0 && this.inputTarget.value.length < 3) {
      return
    }

    let delay = this.inputTarget.value.length === 0 ? 0 : this.delayValue

    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      if (this.inputTarget.value.length > 0 && this.inputTarget.value.length < 3) {
        return
      }

      this.element.requestSubmit()
    }, delay)
  }
}
