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

    this.#registerPageChangingEvent()
  }

  disconnect() {
    this.#cleanup()
  }

  currentPageValueChanged() {
    this.#cleanup()

    this.debounceTimeout = setTimeout(() => {
      this.#fetchPageContent()
    }, 100)
  }

  #registerPageChangingEvent() {
    if (this.iframeTarget.contentWindow?.PDFViewerApplication?.eventBus) {
      this.iframeTarget.contentWindow.PDFViewerApplication.eventBus._on("pagechanging", event => {
        this.currentPageValue = event.pageNumber
      })
    } else {
      setTimeout(() => this.#registerPageChangingEvent(), 100)
    }
  }

  async #fetchPageContent() {
    this.currentAbortController = new AbortController()

    try {
      this.contentTarget.innerHTML = this.skeletonValue

      await get(this.#newPagePath(), {
        responseKind: "turbo-stream",
        signal: this.currentAbortController.signal
      })

      history.replaceState(null, "", this.#newPagePath())
    } catch (error) {
      // Ignore AbortError - it means we cancelled the request intentionally
      if (error.name !== 'AbortError') {
        console.error('Error fetching page content:', error)
      }
    }
  }

  #newPagePath() {
    return `/books/${this.bookIdValue}/files/${this.fileIdValue}/pages/${this.currentPageValue}`
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
