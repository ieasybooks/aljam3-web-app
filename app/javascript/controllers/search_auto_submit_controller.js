import { Controller } from "@hotwired/stimulus"
import { debounce } from "../utils"

// Connects to data-controller="search-auto-submit"
export default class extends Controller {
  static targets = ["input"]
  static values = { delay: { type: Number, default: 150 } }

  connect() {
    this.submit = debounce(this.submit.bind(this), this.delayValue)
  }

  disconnect() {
    this.submit = null
  }

  submit() {
    if (this.inputTarget.value.length === 0) {
      this.element.requestSubmit()
      return
    }

    if (this.inputTarget.value.length < 3) {
      return
    }

    this.element.requestSubmit()
  }
}
