import { Controller } from "@hotwired/stimulus"

const SIZE_TO_CLASS = {
  1: "text-xs",
  2: "text-sm",
  3: "text-base",
  4: "text-lg",
  5: "text-xl",
  6: "text-2xl",
  7: "text-3xl",
  8: "text-4xl",
  9: "text-5xl"
}

// Connects to data-controller="content-controls"
export default class extends Controller {
  static targets = [ "content", "copyTextButton", "iframe", "copyImageButton" ]
  static values = {
    copyTextButtonDoneStatus: String,
    copyImageButtonDoneStatus: String
  }

  connect() {
    this.currentContentSize = parseInt(localStorage.getItem("txt-content-size")) || 3

    this.contentTarget.classList.add(SIZE_TO_CLASS[this.currentContentSize])
  }

  copyText() {
    navigator.clipboard.writeText(this.contentTarget.textContent)

    const oldInnerHTML = this.copyTextButtonTarget.innerHTML

    this.copyTextButtonTarget.setAttribute("disabled", true)
    this.copyTextButtonTarget.innerHTML = this.copyTextButtonDoneStatusValue

    setTimeout(() => {
      this.copyTextButtonTarget.innerHTML = oldInnerHTML
      this.copyTextButtonTarget.removeAttribute("disabled")
    }, 1000)
  }

  textSizeIncrease() {
    this.currentContentSize = this.currentContentSize + 1

    if (this.currentContentSize > 9) {
      this.currentContentSize = 9
    }

    this.contentTarget.classList.remove(SIZE_TO_CLASS[this.currentContentSize - 1])
    this.contentTarget.classList.add(SIZE_TO_CLASS[this.currentContentSize])

    localStorage.setItem("txt-content-size", this.currentContentSize)
  }

  textSizeDecrease() {
    this.currentContentSize = this.currentContentSize - 1

    if (this.currentContentSize < 1) {
      this.currentContentSize = 1
    }

    this.contentTarget.classList.remove(SIZE_TO_CLASS[this.currentContentSize + 1])
    this.contentTarget.classList.add(SIZE_TO_CLASS[this.currentContentSize])

    localStorage.setItem("txt-content-size", this.currentContentSize)
  }

  copyImage() {
    this.#currentPageView().canvas.toBlob(async (blob) => {
      const item = new ClipboardItem({ "image/png": blob })
      await navigator.clipboard.write([item])
    }, "image/png")

    const oldInnerHTML = this.copyImageButtonTarget.innerHTML

    this.copyImageButtonTarget.setAttribute("disabled", true)
    this.copyImageButtonTarget.innerHTML = this.copyImageButtonDoneStatusValue

    setTimeout(() => {
      this.copyImageButtonTarget.innerHTML = oldInnerHTML
      this.copyImageButtonTarget.removeAttribute("disabled")
    }, 1000)
  }

  #currentPageView() {
    return this.iframeTarget.contentWindow.PDFViewerApplication.pdfViewer.getPageView(this.iframeTarget.contentWindow.PDFViewerApplication.page - 1)
  }
}
