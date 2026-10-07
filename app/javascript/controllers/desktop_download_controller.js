import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  open(event) {
    event.preventDefault()
    if (this.dialogTarget.open) return

    this.wasScrollLocked = document.body.classList.contains("overflow-hidden")
    document.body.classList.add("overflow-hidden")
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  dismissBackdrop(event) {
    if (event.target !== this.dialogTarget) return

    const { left, right, top, bottom } = this.dialogTarget.getBoundingClientRect()
    if (event.clientX < left || event.clientX > right || event.clientY < top || event.clientY > bottom) {
      this.close()
    }
  }

  restoreScroll() {
    if (!this.wasScrollLocked) document.body.classList.remove("overflow-hidden")
  }

  beforeCache() {
    if (!this.dialogTarget.open) return

    this.close()
    this.restoreScroll()
  }
}
