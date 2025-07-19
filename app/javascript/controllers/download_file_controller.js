import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="download-file"
export default class extends Controller {
  static values = {
    url: String,
    loadingStatus: String,
    filename: String,
  }

  async download() {
    this.element.setAttribute("disabled", true)

    const oldInnerHTML = this.element.innerHTML
    this.element.innerHTML = this.loadingStatusValue

    const response = await fetch(this.urlValue)
    const blob = await response.blob()
    const url = window.URL.createObjectURL(blob)

    const a = document.createElement("a")
    a.href = url
    a.download = this.filenameValue

    document.body.appendChild(a)

    a.click()
    a.remove()

    window.URL.revokeObjectURL(url)

    this.element.innerHTML = oldInnerHTML
    this.element.removeAttribute("disabled")
  }
}
