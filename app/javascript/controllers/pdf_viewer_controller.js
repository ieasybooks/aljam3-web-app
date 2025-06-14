import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

// Connects to data-controller="pdf-viewer"
export default class extends Controller {
  static targets = [ "iframe", "content" ]
  static values = {
    bookId: Number,
    fileId: Number,
    currentPage: Number,
    skeleton: String,
  }

  connect() {
    this.currentAbortController = null
    this.debounceTimeout = null
    this.currentPage = this.currentPageValue

    this.#registerPageChangingEvent()
  }

  disconnect() {
    this.#cleanup()
  }

  #registerPageChangingEvent() {
    if (this.iframeTarget.contentWindow?.PDFViewerApplication?.eventBus) {
      this.iframeTarget.contentWindow.PDFViewerApplication.eventBus._on("pagechanging", event => {
        this.#handlePageChange(event.pageNumber)
      })
    } else {
      setTimeout(() => this.#registerPageChangingEvent(), 100)
    }
  }

  #handlePageChange(pageNumber) {
    this.#cleanup()

    this.debounceTimeout = setTimeout(() => {
      this.#fetchPageContent(pageNumber)
    }, 100)
  }

  async #fetchPageContent(pageNumber) {
    if (pageNumber === this.currentPage) {
      return
    }

    this.currentAbortController = new AbortController()

    try {
      this.contentTarget.innerHTML = this.skeletonValue

      await get(this.#newPagePath(pageNumber), {
        responseKind: "turbo-stream",
        signal: this.currentAbortController.signal
      })

      this.currentPage = pageNumber

      history.replaceState(null, "", this.#newPagePath(pageNumber))
    } catch (error) {
      // Ignore AbortError - it means we cancelled the request intentionally
      if (error.name !== 'AbortError') {
        console.error('Error fetching page content:', error)
      }
    }
  }

  #newPagePath(pageNumber) {
    return `/books/${this.bookIdValue}/files/${this.fileIdValue}/pages/${pageNumber}`
  }

  #cleanup() {
    if (this.currentAbortController) {
      this.currentAbortController.abort()
    }

    if (this.debounceTimeout) {
      clearTimeout(this.debounceTimeout)
    }
  }
}
