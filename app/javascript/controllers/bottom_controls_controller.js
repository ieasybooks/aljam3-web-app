import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bottom-controls"
export default class extends Controller {
  static targets = [
    "iframe",
    "previousFileContainer",
    "previousFileButtonTooltip",
    "previousPageContainer",
    "firstPageButton",
    "firstPageButtonTooltip",
    "previousPageButton",
    "previousPageButtonTooltip",
    "nextPageContainer",
    "nextPageButton",
    "nextPageButtonTooltip",
    "lastPageButton",
    "lastPageButtonTooltip",
    "nextFileContainer",
    "nextFileButtonTooltip",
  ]

  static values = {
    totalPages: Number,
  }

  connect() {
    this.#updateButtonStates()
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

  iframeTargetConnected() {
    this.#registerPageChangingEvent()
  }

  #registerPageChangingEvent() {
    if (this.iframeTarget.contentWindow?.PDFViewerApplication?.eventBus) {
      this.iframeTarget.contentWindow.PDFViewerApplication.eventBus._on("pagechanging", (event) => {
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
      this.previousPageContainerTarget.classList.add("hidden")
      this.firstPageButtonTooltipTarget.classList.add("hidden")
      this.previousPageButtonTooltipTarget.classList.add("hidden")

      this.previousFileContainerTarget.classList.remove("hidden")
      this.previousFileButtonTooltipTarget.classList.remove("hidden")
    } else {
      this.previousPageContainerTarget.classList.remove("hidden")
      this.firstPageButtonTooltipTarget.classList.remove("hidden")
      this.previousPageButtonTooltipTarget.classList.remove("hidden")

      this.previousFileContainerTarget.classList.add("hidden")
      this.previousFileButtonTooltipTarget.classList.add("hidden")
    }

    const isLastPage = this.currentPage === this.totalPagesValue
    this.nextPageButtonTarget.disabled = isLastPage
    this.lastPageButtonTarget.disabled = isLastPage

    if (isLastPage) {
      this.nextPageContainerTarget.classList.add("hidden")
      this.nextPageButtonTooltipTarget.classList.add("hidden")
      this.lastPageButtonTooltipTarget.classList.add("hidden")

      this.nextFileContainerTarget.classList.remove("hidden")
      this.nextFileButtonTooltipTarget.classList.remove("hidden")
    } else {
      this.nextPageContainerTarget.classList.remove("hidden")
      this.nextPageButtonTooltipTarget.classList.remove("hidden")
      this.lastPageButtonTooltipTarget.classList.remove("hidden")

      this.nextFileContainerTarget.classList.add("hidden")
      this.nextFileButtonTooltipTarget.classList.add("hidden")
    }
  }

  get currentPage() {
    return parseInt(this.element.dataset.pdfViewerCurrentPageValue)
  }

  set currentPage(value) {
    this.element.dataset.pdfViewerCurrentPageValue = value.toString()
  }
}
