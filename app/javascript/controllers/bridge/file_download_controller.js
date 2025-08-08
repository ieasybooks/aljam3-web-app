import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

// Connects to data-controller="bridge--file-download"
export default class extends BridgeComponent {
  static component = "file-download"
  static values = {
    url: String,
    filename: String,
    loadingStatus: String,
  }

  download() {
    this.element.setAttribute("disabled", true)

    const oldInnerHTML = this.element.innerHTML
    this.element.innerHTML = this.loadingStatusValue

    this.send(
      "download",
      {
        url: this.urlValue,
        filename: this.filenameValue,
      },
      (message) => {
        if (message.data.loading) {
          return
        }

        this.element.innerHTML = oldInnerHTML
        this.element.removeAttribute("disabled")

        if (!message.data.success) {
          this.#showError(message.data.error)
        }
      },
    )
  }

  #showError(message) {
    if (window.alert) {
      alert(`Download failed: ${message}`)
    }
  }
}
