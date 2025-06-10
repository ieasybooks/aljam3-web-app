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

// Connects to data-controller="top-controls"
export default class extends Controller {
  static targets = [
    "txtContent",
    "content",
    "copyTextButton",

    "txtContentOnlyButton",
    "txtAndPdfContentButton",
    "pdfContentOnlyButton",

    "pdfContent",
    "iframe",
    "downloadImageButton",
    "copyImageButton"
  ]

  static values = {
    bookTitle: String,
    copyTextButtonDoneStatus: String,
    downloadImageButtonDoneStatus: String,
    copyImageButtonDoneStatus: String
  }

  connect() {
    this.currentContentSize = parseInt(localStorage.getItem("txt-content-size")) || 3
    
    const defaultLayout = this.#isMobile() ? "pdf-only" : "txt-and-pdf"
    this.currentLayout = localStorage.getItem("content-layout") || defaultLayout

    this.contentTarget.classList.add(SIZE_TO_CLASS[this.currentContentSize])
    this.#applyLayout()
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

  txtContentOnly() {
    this.currentLayout = "txt-only"
    localStorage.setItem("content-layout", this.currentLayout)
    this.#applyLayout()
  }

  txtAndPdfContent() {
    this.currentLayout = "txt-and-pdf"
    localStorage.setItem("content-layout", this.currentLayout)
    this.#applyLayout()
  }

  pdfContentOnly() {
    this.currentLayout = "pdf-only"
    localStorage.setItem("content-layout", this.currentLayout)
    this.#applyLayout()
  }

  downloadImage() {
    const link = document.createElement("a")
    link.href = this.#currentPageView().canvas.toDataURL("image/png")
    link.download = `${this.bookTitleValue}-${this.iframeTarget.contentWindow.PDFViewerApplication.page}.png`
    link.click()

    const oldInnerHTML = this.downloadImageButtonTarget.innerHTML

    this.downloadImageButtonTarget.setAttribute("disabled", true)
    this.downloadImageButtonTarget.innerHTML = this.downloadImageButtonDoneStatusValue

    setTimeout(() => {
      this.downloadImageButtonTarget.innerHTML = oldInnerHTML
      this.downloadImageButtonTarget.removeAttribute("disabled")
    }, 1000)
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

  #applyLayout() {
    this.txtContentOnlyButtonTarget.classList.remove("bg-neutral-200!")
    this.txtAndPdfContentButtonTarget.classList.remove("bg-neutral-200!")
    this.pdfContentOnlyButtonTarget.classList.remove("bg-neutral-200!")

    switch (this.currentLayout) {
      case "txt-only":
        this.txtContentOnlyButtonTarget.classList.add("bg-neutral-200!")
        this.txtContentTarget.classList.remove("hidden")
        this.pdfContentTarget.classList.add("hidden")
        break
      case "pdf-only":
        this.pdfContentOnlyButtonTarget.classList.add("bg-neutral-200!")
        this.txtContentTarget.classList.add("hidden")
        this.pdfContentTarget.classList.remove("hidden")
        break
      case "txt-and-pdf":
      default:
        this.txtAndPdfContentButtonTarget.classList.add("bg-neutral-200!")
        this.txtContentTarget.classList.remove("hidden")
        this.pdfContentTarget.classList.remove("hidden")
        break
    }
  }

  #currentPageView() {
    return this.iframeTarget.contentWindow.PDFViewerApplication.pdfViewer.getPageView(this.iframeTarget.contentWindow.PDFViewerApplication.page - 1)
  }

  #isMobile() {
    return window.innerWidth < 640 // Tailwind's sm breakpoint
  }
}
