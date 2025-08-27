import { Controller } from "@hotwired/stimulus"

const SIZE_TO_TEXT_CLASS = {
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

const SIZE_TO_LEADING_CLASS = {
  1: "leading-5",
  2: "leading-5.5",
  3: "leading-6.5",
  4: "leading-7",
  5: "leading-8",
  6: "leading-9.5",
  7: "leading-11.5",
  8: "leading-13",
  9: "leading-18",
}

// Connects to data-controller="top-controls"
export default class extends Controller {
  static targets = [
    "header",
    "topControlsBar",
    "contentContainer",
    "bottomControlsBar",

    "txtIndicator",
    "txtContent",
    "content",
    "copyTextButton",

    "fullscreenIcon",
    "exitFullscreenIcon",

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

    "txtOnlyOption",
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

    this.contentTarget.classList.add(
      SIZE_TO_TEXT_CLASS[this.currentContentSize],
      SIZE_TO_LEADING_CLASS[this.currentContentSize],
    )

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

  fullscreen() {
    this.headerTarget.classList.toggle("hidden")

    const containerClasses = ["px-4", "sm:px-4", "py-4", "space-y-4"]
    containerClasses.forEach((className) => {
      this.element.classList.toggle(className)
    })

    const pageSectionsClasses = ["rounded-xl", "border"]
    pageSectionsClasses.forEach((className) => {
      this.topControlsBarTarget.classList.toggle(className)
      this.txtContentTarget.classList.toggle(className)
      this.pdfContentTarget.classList.toggle(className)
      this.bottomControlsBarTarget.classList.toggle(className)
    })

    this.fullscreenIconTarget.classList.toggle("hidden")
    this.exitFullscreenIconTarget.classList.toggle("hidden")
  }

  textSizeIncrease() {
    this.currentContentSize = this.currentContentSize + 1

    if (this.currentContentSize > 9) {
      this.currentContentSize = 9
    }

    this.contentTarget.classList.remove(
      SIZE_TO_TEXT_CLASS[this.currentContentSize - 1],
      SIZE_TO_LEADING_CLASS[this.currentContentSize - 1],
    )
    this.contentTarget.classList.add(
      SIZE_TO_TEXT_CLASS[this.currentContentSize],
      SIZE_TO_LEADING_CLASS[this.currentContentSize],
    )

    localStorage.setItem("txt-content-size", this.currentContentSize)
  }

  textSizeDecrease() {
    this.currentContentSize = this.currentContentSize - 1

    if (this.currentContentSize < 1) {
      this.currentContentSize = 1
    }

    this.contentTarget.classList.remove(
      SIZE_TO_TEXT_CLASS[this.currentContentSize + 1],
      SIZE_TO_LEADING_CLASS[this.currentContentSize + 1],
    )
    this.contentTarget.classList.add(
      SIZE_TO_TEXT_CLASS[this.currentContentSize],
      SIZE_TO_LEADING_CLASS[this.currentContentSize],
    )

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

  updateTashkeelContent() {
    this.originalContent = this.contentTarget.innerHTML

    if (this.showingTashkeel) {
      this.contentTarget.innerHTML = this.originalContent
    } else {
      this.contentTarget.innerHTML = this.#removeTashkeel(this.originalContent)
    }
  }

  #initializeTashkeel() {
    this.originalContent = this.contentTarget.innerHTML
    this.showingTashkeel = true
  }

  #applyLayout() {
    const buttonActiveClasses = ["bg-neutral-200!", "dark:bg-neutral-700!"]
    const pdfContentActiveClassesToAdd = ["sm:max-w-1/2", "flex-1", "flex", "flex-col", "border"]
    const pdfContentActiveClassesToRemove = ["w-0"]

    this.contentContainerTarget.classList.add("gap-2", "sm:gap-4")

    this.txtIndicatorTarget.innerHTML = this.txtIndicatorTargetHTMLContent

    this.txtContentOnlyButtonTarget.classList.remove(...buttonActiveClasses)
    this.txtAndPdfContentButtonTarget.classList.remove(...buttonActiveClasses)
    this.pdfContentOnlyButtonTarget.classList.remove(...buttonActiveClasses)

    this.pdfIndicatorTarget.innerHTML = this.pdfIndicatorTargetHTMLContent

    this.txtOnlyOptionTargets.forEach((option) => {
      option.classList.remove("hidden")
    })

    switch (this.currentLayout) {
      case "txt-only":
        this.contentContainerTarget.classList.remove("gap-2", "sm:gap-4")

        this.txtContentOnlyButtonTarget.classList.add(...buttonActiveClasses)

        this.txtContentTarget.classList.remove("hidden")

        this.pdfContentTarget.classList.add(...pdfContentActiveClassesToRemove)
        this.pdfContentTarget.classList.remove(...pdfContentActiveClassesToAdd)

        this.pdfIndicatorTarget.innerHTML = ""
        break
      case "pdf-only":
        this.contentContainerTarget.classList.remove("gap-2", "sm:gap-4")

        this.txtIndicatorTarget.innerHTML = ""

        this.pdfContentOnlyButtonTarget.classList.add(...buttonActiveClasses)

        this.txtContentTarget.classList.add("hidden")

        this.pdfContentTarget.classList.remove(...pdfContentActiveClassesToRemove)
        this.pdfContentTarget.classList.add(...pdfContentActiveClassesToAdd)

        this.txtOnlyOptionTargets.forEach((option) => {
          option.classList.add("hidden")
        })
        break
      case "txt-and-pdf":
      default:
        this.txtAndPdfContentButtonTarget.classList.add(...buttonActiveClasses)

        this.txtContentTarget.classList.remove("hidden")

        this.pdfContentTarget.classList.remove(...pdfContentActiveClassesToRemove)
        this.pdfContentTarget.classList.add(...pdfContentActiveClassesToAdd)
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
