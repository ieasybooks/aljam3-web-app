import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="txt-content"
export default class extends Controller {
  static targets = [ "content", "copyButton" ]
  static values = {
    copyButtonDoneStatus: String
  }

  copy() {
    navigator.clipboard.writeText(this.contentTarget.textContent)

    const oldInnerHTML = this.copyButtonTarget.innerHTML

    this.copyButtonTarget.setAttribute("disabled", true)
    this.copyButtonTarget.innerHTML = this.copyButtonDoneStatusValue

    setTimeout(() => {
      this.copyButtonTarget.innerHTML = oldInnerHTML
      this.copyButtonTarget.removeAttribute("disabled")
    }, 1000)
  }
}
