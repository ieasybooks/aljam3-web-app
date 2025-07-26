import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

// Connects to data-controller="pdf-viewer"
export default class extends Controller {
  static targets = ["iframe", "content", "progress"]
  static values = {
    bookId: Number,
    fileId: Number,
    currentPage: Number,
    skeleton: String,
    loadingError: String,
    totalPages: Number,
  }

  connect() {
    this.internalCurrentPage = this.currentPageValue
    this.currentAbortController = null
    this.debounceTimeout = null
    this.currentObserver = null

    this.#registerPageChangingEvent()
  }

  disconnect() {
    this.#cleanup()
  }

  currentPageValueChanged() {
    this.#cleanup()

    this.debounceTimeout = setTimeout(() => {
      this.progressTarget.style.width = `${(this.currentPageValue / this.totalPagesValue) * 100}%`

      if (this.currentPageValue === this.internalCurrentPage) {
        return
      }

      this.#fetchPageContent()
      this.internalCurrentPage = this.currentPageValue
    }, 100)
  }

  #registerPageChangingEvent() {
    if (this.iframeTarget.contentWindow?.PDFViewerApplication?.eventBus) {
      this.#hideNonFunctionalButtons()

      this.iframeTarget.contentWindow.PDFViewerApplication.eventBus._on("pagechanging", (event) => {
        this.currentPageValue = event.pageNumber
      })
    } else {
      setTimeout(() => this.#registerPageChangingEvent(), 100)
    }
  }

  #hideNonFunctionalButtons() {
    const iframeDocument = this.iframeTarget.contentWindow.document

    iframeDocument.querySelector("#viewFind")?.classList.add("hidden")
    iframeDocument.querySelector("#viewAttachments")?.classList.add("hidden")
    iframeDocument.querySelector("#viewLayers")?.classList.add("hidden")
    iframeDocument.querySelector("#secondaryOpenFile")?.classList.add("hidden")
    iframeDocument.querySelector("#secondaryPrint")?.classList.add("hidden")
    iframeDocument.querySelector("#viewBookmark")?.classList.add("hidden")
    iframeDocument.querySelector("#cursorToolButtons")?.classList.add("hidden")
    iframeDocument.querySelector("#cursorToolButtons + .horizontalToolbarSeparator")?.classList.add("hidden")
    iframeDocument.querySelector("#scrollModeButtons")?.classList.add("hidden")
    iframeDocument.querySelector("#scrollModeButtons + .horizontalToolbarSeparator")?.classList.add("hidden")
  }

  async #fetchPageContent() {
    this.currentAbortController = new AbortController()

    try {
      this.contentTarget.innerHTML = this.skeletonValue

      this.currentObserver = new MutationObserver(() => {
        if (this.contentTarget.innerHTML !== this.skeletonValue) {
          this.currentObserver.disconnect()
          this.currentObserver = null

          window.dispatchEvent(new CustomEvent("update-tashkeel-content"))
        }
      })

      this.currentObserver.observe(this.contentTarget, {
        childList: true,
        subtree: true,
      })

      await get(this.#newPagePath(), {
        responseKind: "turbo-stream",
        signal: this.currentAbortController.signal,
      })

      history.replaceState(null, "", this.#newPagePath())
    } catch (error) {
      // Ignore AbortError - it means we cancelled the request intentionally
      if (error.name !== "AbortError") {
        this.contentTarget.innerHTML = this.loadingErrorValue
      }
    }
  }

  #newPagePath() {
    return `/${this.bookIdValue}/${this.fileIdValue}/${this.currentPageValue}`
  }

  #cleanup() {
    if (this.currentAbortController) {
      this.currentAbortController.abort()
    }

    if (this.debounceTimeout) {
      clearTimeout(this.debounceTimeout)
    }

    if (this.currentObserver) {
      this.currentObserver.disconnect()
      this.currentObserver = null
    }
  }
}
