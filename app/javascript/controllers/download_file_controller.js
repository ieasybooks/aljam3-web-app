import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="download-file"
export default class extends Controller {
  static values = {
    url: String
  }

  async download() {
    const response = await fetch(this.urlValue)
    const blob = await response.blob()
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = this.urlValue.split("/").pop()
    document.body.appendChild(a)
    a.click()
    a.remove()
    window.URL.revokeObjectURL(url)
  }
}
