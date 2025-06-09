import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

// Connects to data-controller="pdf-reader"
export default class extends Controller {
  static targets = [ "iframe" ]
  static values = {
    bookId: Number
  }

  connect() {
    this.currentAbortController = null
    this.debounceTimeout = null

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
    this.currentAbortController = new AbortController()

    try {
      await get(this.#newPagePath(pageNumber), { 
        responseKind: "turbo-stream",
        signal: this.currentAbortController.signal
      })
    } catch (error) {
      // Ignore AbortError - it means we cancelled the request intentionally
      if (error.name !== 'AbortError') {
        console.error('Error fetching page content:', error)
      }
    }
  }

  #newPagePath(pageNumber) {
    return `/books/${this.bookIdValue}/pages/${pageNumber}`
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
