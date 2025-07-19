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

  static values = {
    totalPages: Number
  }

  connect() {
    this.#updateButtonStates()
    this.#registerPageChangingEvent()
  }

  firstPage() {
    this.currentPage = 1
    this.#updateButtonStates()

    // Update PDF.js page number at the end as it could be undefined/null and cause issues.
    this.iframeTarget.contentWindow.PDFViewerApplication.page = 1
  }

  previousPage() {
    if (this.currentPage > 1) {
      this.currentPage = this.currentPage - 1
    }

    this.#updateButtonStates()

    // Update PDF.js page number at the end as it could be undefined/null and cause issues.
    this.iframeTarget.contentWindow.PDFViewerApplication.page = this.currentPage
  }

  nextPage() {
    if (this.currentPage < this.totalPagesValue) {
      this.currentPage = this.currentPage + 1
    }

    this.#updateButtonStates()

    // Update PDF.js page number at the end as it could be undefined/null and cause issues.
    this.iframeTarget.contentWindow.PDFViewerApplication.page = this.currentPage
  }

  lastPage() {
    this.currentPage = this.totalPagesValue
    this.#updateButtonStates()

    // Update PDF.js page number at the end as it could be undefined/null and cause issues.
    this.iframeTarget.contentWindow.PDFViewerApplication.page = this.totalPagesValue
  }

  #registerPageChangingEvent() {
    if (this.iframeTarget.contentWindow?.PDFViewerApplication?.eventBus) {
      this.iframeTarget.contentWindow.PDFViewerApplication.eventBus._on("pagechanging", event => {
        this.#updateButtonStates()
      })
    } else {
      setTimeout(() => this.#registerPageChangingEvent(), 100)
    }
  }

  #updateButtonStates() {
    const isFirstPage = this.currentPage === 1
    this.firstPageButtonTarget.disabled = isFirstPage
    this.previousPageButtonTarget.disabled = isFirstPage

    if (isFirstPage) {
      this.firstPageButtonTooltipTarget.classList.add("hidden")
      this.previousPageButtonTooltipTarget.classList.add("hidden")
    } else {
      this.firstPageButtonTooltipTarget.classList.remove("hidden")
      this.previousPageButtonTooltipTarget.classList.remove("hidden")
    }

    const isLastPage = this.currentPage === this.totalPagesValue
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

  get currentPage() {
    return parseInt(this.element.dataset.pdfViewerCurrentPageValue)
  }

  set currentPage(value) {
    this.element.dataset.pdfViewerCurrentPageValue = value.toString()
  }
}
