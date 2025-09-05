import { Controller } from "@hotwired/stimulus"
import Cropper from "cropperjs"

// Connects to data-controller="cropperjs"
export default class extends Controller {
  static targets = ["container", "iframe", "rotationValue"]

  connect() {
    this.cropper = null
    this.rotation = 0
  }

  rotate(event) {
    document.querySelector("cropper-image").$rotate(`${event.target.value - this.rotation}deg`)
    this.rotation = event.target.value
    this.rotationValueTarget.textContent = `(${this.rotation})`
  }

  download() {
    document
      .querySelector("cropper-selection")
      .$toCanvas()
      .then((canvas) => {
        const link = document.createElement("a")
        link.href = canvas.toDataURL("image/png")
        link.download = `${this.containerTarget.dataset.bookTitle}-${this.iframeTarget.contentWindow.PDFViewerApplication.page}.png`
        link.click()
      })
  }

  containerTargetConnected() {
    try {
      const dataURL = this.#currentPageView().canvas.toDataURL("image/png")

      const img = document.createElement("img")
      img.src = dataURL

      this.containerTarget.innerHTML = ""
      this.containerTarget.appendChild(img)

      this.cropper = new Cropper(img)
    } catch {
      // Ignore
    }
  }

  #currentPageView() {
    return this.iframeTarget.contentWindow.PDFViewerApplication.pdfViewer.getPageView(
      this.iframeTarget.contentWindow.PDFViewerApplication.page - 1,
    )
  }
}
