import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bottom-controls"
export default class extends Controller {
  static targets = [
    "iframe",
    "firstPageButton",
    "firstPageButtonTooltip",
    "previousPageButton",
    "previousPageButtonTooltip",
    "nextPageButton",
    "nextPageButtonTooltip",
    "lastPageButton",
    "lastPageButtonTooltip"
  ]

  connect() {
    this.#registerPageChangingEvent()
  }

  firstPage() {
    this.iframeTarget.contentWindow.PDFViewerApplication.page = 1

    this.#updateButtonStates()
  }

  previousPage() {
    this.iframeTarget.contentWindow.PDFViewerApplication.pdfViewer.previousPage()

    this.#updateButtonStates()
  }

  nextPage() {
    this.iframeTarget.contentWindow.PDFViewerApplication.pdfViewer.nextPage()

    this.#updateButtonStates()
  }

  lastPage() {
    this.iframeTarget.contentWindow.PDFViewerApplication.page = this.iframeTarget.contentWindow.PDFViewerApplication.pdfViewer.pagesCount

    this.#updateButtonStates()
  }

  #registerPageChangingEvent() {
    if (this.iframeTarget.contentWindow?.PDFViewerApplication?.eventBus &&
        this.iframeTarget.contentWindow?.PDFViewerApplication?.pdfViewer?.pagesCount > 0) {
      this.#updateButtonStates()

      this.iframeTarget.contentWindow.PDFViewerApplication.eventBus._on("pagechanging", event => {
        this.#updateButtonStates()
      })
    } else {
      setTimeout(() => this.#registerPageChangingEvent(), 100)
    }
  }

  #updateButtonStates() {
    const currentPage = this.iframeTarget.contentWindow.PDFViewerApplication.page
    const totalPages = this.iframeTarget.contentWindow.PDFViewerApplication.pdfViewer.pagesCount

    const isFirstPage = currentPage === 1
    this.firstPageButtonTarget.disabled = isFirstPage
    this.previousPageButtonTarget.disabled = isFirstPage

    if (isFirstPage) {
      this.firstPageButtonTooltipTarget.classList.add("hidden")
      this.previousPageButtonTooltipTarget.classList.add("hidden")
    } else {
      this.firstPageButtonTooltipTarget.classList.remove("hidden")
      this.previousPageButtonTooltipTarget.classList.remove("hidden")
    }

    const isLastPage = currentPage === totalPages
    this.nextPageButtonTarget.disabled = isLastPage
    this.lastPageButtonTarget.disabled = isLastPage

    if (isLastPage) {
      this.nextPageButtonTooltipTarget.classList.add("hidden")
      this.lastPageButtonTooltipTarget.classList.add("hidden")
    } else {
      this.nextPageButtonTooltipTarget.classList.remove("hidden")
      this.lastPageButtonTooltipTarget.classList.remove("hidden")
    }
  }
}
