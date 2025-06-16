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
    currentPage: Number,
    totalPages: Number
  }

  connect() {
    this.#updateButtonStates()
  }

  firstPage() {
    this.currentPageValue = 1
    this.#updateButtonStates()

    // Update PDF.js page number at the end as it could be undefined/null and cause issues.
    this.iframeTarget.contentWindow.PDFViewerApplication.page = 1
  }

  previousPage() {
    if (this.currentPageValue > 1) {
      this.currentPageValue = this.currentPageValue - 1
    }

    this.#updateButtonStates()

    // Update PDF.js page number at the end as it could be undefined/null and cause issues.
    this.iframeTarget.contentWindow.PDFViewerApplication.pdfViewer.previousPage()
  }

  nextPage() {
    if (this.currentPageValue < this.totalPagesValue) {
      this.currentPageValue = this.currentPageValue + 1
    }

    this.#updateButtonStates()

    // Update PDF.js page number at the end as it could be undefined/null and cause issues.
    this.iframeTarget.contentWindow.PDFViewerApplication.pdfViewer.nextPage()
  }

  lastPage() {
    this.currentPageValue = this.totalPagesValue
    this.#updateButtonStates()

    // Update PDF.js page number at the end as it could be undefined/null and cause issues.
    this.iframeTarget.contentWindow.PDFViewerApplication.page = this.iframeTarget.contentWindow.PDFViewerApplication.pdfViewer.pagesCount
  }

  #updateButtonStates() {
    const isFirstPage = this.currentPageValue === 1
    this.firstPageButtonTarget.disabled = isFirstPage
    this.previousPageButtonTarget.disabled = isFirstPage

    if (isFirstPage) {
      this.firstPageButtonTooltipTarget.classList.add("hidden")
      this.previousPageButtonTooltipTarget.classList.add("hidden")
    } else {
      this.firstPageButtonTooltipTarget.classList.remove("hidden")
      this.previousPageButtonTooltipTarget.classList.remove("hidden")
    }

    const isLastPage = this.currentPageValue === this.totalPagesValue
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
