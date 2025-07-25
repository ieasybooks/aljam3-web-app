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
  9: "text-5xl",
}

// Connects to data-controller="top-controls"
export default class extends Controller {
  static targets = [
    "txtIndicator",
    "txtContent",
    "content",
    "copyTextButton",

    "tashkeelToggleButton",
    "tashkeelToggleTooltip",
    "mobileTashkeelToggleButton",
    "showTashkeelToggleIcon",
    "hideTashkeelToggleIcon",
    "mobileShowTashkeelToggleIcon",
    "mobileHideTashkeelToggleIcon",

    "txtContentOnlyButton",
    "txtAndPdfContentButton",
    "pdfContentOnlyButton",

    "pdfIndicator",
    "pdfContent",
    "iframe",
    "downloadImageButton",
    "copyImageButton",
  ]

  static values = {
    bookTitle: String,
    copyTextButtonDoneStatus: String,
    downloadImageButtonDoneStatus: String,
    copyImageButtonDoneStatus: String,
    hideTashkeelText: String,
    showTashkeelText: String,
  }

  connect() {
    this.txtIndicatorTargetHTMLContent = this.txtIndicatorTarget.innerHTML
    this.pdfIndicatorTargetHTMLContent = this.pdfIndicatorTarget.innerHTML

    this.currentContentSize = parseInt(localStorage.getItem("txt-content-size")) || 3

    const defaultLayout = this.#isMobile() ? "pdf-only" : "txt-and-pdf"
    this.currentLayout = localStorage.getItem("content-layout") || defaultLayout

    this.contentTarget.classList.add(SIZE_TO_CLASS[this.currentContentSize])

    this.#initializeTashkeel()
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

  toggleTashkeel() {
    this.showingTashkeel = !this.showingTashkeel

    if (this.showingTashkeel) {
      this.contentTarget.innerHTML = this.originalContent
    } else {
      this.contentTarget.innerHTML = this.#removeTashkeel(this.originalContent)
    }

    this.#updateTashkeelToggleUI()
  }

  #initializeTashkeel() {
    this.originalContent = this.contentTarget.innerHTML
    this.showingTashkeel = true
  }

  #applyLayout() {
    this.txtIndicatorTarget.innerHTML = this.txtIndicatorTargetHTMLContent

    this.txtContentOnlyButtonTarget.classList.remove("bg-neutral-200!", "dark:bg-neutral-700!")
    this.txtAndPdfContentButtonTarget.classList.remove("bg-neutral-200!", "dark:bg-neutral-700!")
    this.pdfContentOnlyButtonTarget.classList.remove("bg-neutral-200!", "dark:bg-neutral-700!")

    this.pdfIndicatorTarget.innerHTML = this.pdfIndicatorTargetHTMLContent

    switch (this.currentLayout) {
      case "txt-only":
        this.txtContentOnlyButtonTarget.classList.add("bg-neutral-200!", "dark:bg-neutral-700!")
        this.txtContentTarget.classList.remove("hidden")
        this.pdfContentTarget.classList.add("hidden")

        this.pdfIndicatorTarget.innerHTML = ""
        break
      case "pdf-only":
        this.txtIndicatorTarget.innerHTML = ""

        this.pdfContentOnlyButtonTarget.classList.add("bg-neutral-200!", "dark:bg-neutral-700!")
        this.txtContentTarget.classList.add("hidden")
        this.pdfContentTarget.classList.remove("hidden")
        break
      case "txt-and-pdf":
      default:
        this.txtAndPdfContentButtonTarget.classList.add("bg-neutral-200!", "dark:bg-neutral-700!")
        this.txtContentTarget.classList.remove("hidden")
        this.pdfContentTarget.classList.remove("hidden")
        break
    }
  }

  #removeTashkeel(text) {
    // Arabic diacritics Unicode ranges:
    // \u064B-\u0652: Fathatan, Dammatan, Kasratan, Fatha, Damma, Kasra, Shadda, Sukun
    // \u0653-\u0655: Maddah, Hamza above, Hamza below
    // \u0656-\u065F: Various diacritics
    // \u0670: Superscript Alef
    // \u06D6-\u06ED: Various Quranic marks
    // \u08D4-\u08E1: Arabic small high marks
    // \u08E3-\u08FF: Extended Arabic diacritics

    const tashkeelRegex = /[\u064B-\u0652\u0653-\u0655\u0656-\u065F\u0670\u06D6-\u06ED\u08D4-\u08E1\u08E3-\u08FF]/g

    return text.replace(tashkeelRegex, "")
  }

  #updateTashkeelToggleUI() {
    if (this.showingTashkeel) {
      this.showTashkeelToggleIconTarget.classList.remove("hidden")
      this.hideTashkeelToggleIconTarget.classList.add("hidden")
    } else {
      this.showTashkeelToggleIconTarget.classList.add("hidden")
      this.hideTashkeelToggleIconTarget.classList.remove("hidden")
    }

    if (this.showingTashkeel) {
      this.mobileShowTashkeelToggleIconTarget.classList.remove("hidden")
      this.mobileHideTashkeelToggleIconTarget.classList.add("hidden")
    } else {
      this.mobileShowTashkeelToggleIconTarget.classList.add("hidden")
      this.mobileHideTashkeelToggleIconTarget.classList.remove("hidden")
    }

    const tashkeelText = this.showingTashkeel ? this.hideTashkeelTextValue : this.showTashkeelTextValue

    this.tashkeelToggleTooltipTarget.querySelector("p").textContent = tashkeelText
    this.mobileTashkeelToggleButtonTarget.textContent = tashkeelText
  }

  #currentPageView() {
    return this.iframeTarget.contentWindow.PDFViewerApplication.pdfViewer.getPageView(
      this.iframeTarget.contentWindow.PDFViewerApplication.page - 1,
    )
  }

  #isMobile() {
    return window.innerWidth < 640 // Tailwind's sm breakpoint
  }
}
