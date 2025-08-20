import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

// Connects to data-controller="pdf-viewer"
export default class extends Controller {
  static targets = ["iframe", "content", "progress", "shareDialog", "bridgeShare"]
  static values = {
    bookId: Number,
    fileId: Number,
    currentPage: Number,
    skeleton: String,
    loadingError: String,
    totalPages: Number,
    cacheSize: { type: Number, default: 500 }
  }

  connect() {
    this.internalCurrentPage = this.currentPageValue
    this.currentAbortController = null
    this.debounceTimeout = null
    this.currentObserver = null
    
    this.#initializePageCache()
    this.#registerPageChangingEvent()
  }

  disconnect() {
    this.#cleanup()
    this.pageCache?.clear()
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

  #initializePageCache() {
    const cacheKey = `${this.bookIdValue}-${this.fileIdValue}`
    
    if (this.currentBookCacheKey !== cacheKey) {
      this.pageCache?.clear()
      this.currentBookCacheKey = cacheKey
    }
    
    if (!this.pageCache) {
      this.pageCache = new Map()
      this.cacheOrder = []
    }
  }

  #getCachedPage(pageNumber) {
    const cacheKey = `${this.bookIdValue}-${this.fileIdValue}-${pageNumber}`
    
    if (this.pageCache.has(cacheKey)) {
      const index = this.cacheOrder.indexOf(cacheKey)
      if (index > -1) {
        this.cacheOrder.splice(index, 1)
        this.cacheOrder.push(cacheKey)
      }
      
      return this.pageCache.get(cacheKey)
    }
    
    return null
  }

  #setCachedPage(pageNumber, content) {
    const cacheKey = `${this.bookIdValue}-${this.fileIdValue}-${pageNumber}`
    
    if (this.pageCache.has(cacheKey)) {
      const index = this.cacheOrder.indexOf(cacheKey)
      if (index > -1) {
        this.cacheOrder.splice(index, 1)
      }
    }
    
    this.pageCache.set(cacheKey, content)
    this.cacheOrder.push(cacheKey)
    
    while (this.cacheOrder.length > this.cacheSizeValue) {
      const oldestKey = this.cacheOrder.shift()
      this.pageCache.delete(oldestKey)
    }
  }

  async #fetchPageContent() {
    const cachedContent = this.#getCachedPage(this.currentPageValue)
    if (cachedContent) {
      this.contentTarget.innerHTML = cachedContent
      this.#updateShareDialogUrl()
      this.#updateNativeShareUrl()
      history.replaceState(null, "", this.#newPagePath())
      
      window.dispatchEvent(new CustomEvent("update-tashkeel-content"))
      return
    }

    this.currentAbortController = new AbortController()

    try {
      this.contentTarget.innerHTML = this.skeletonValue

      this.currentObserver = new MutationObserver(() => {
        if (this.contentTarget.innerHTML !== this.skeletonValue) {
          this.currentObserver.disconnect()
          this.currentObserver = null

          this.#setCachedPage(this.currentPageValue, this.contentTarget.innerHTML)
          
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

      this.#updateShareDialogUrl()
      this.#updateNativeShareUrl()
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

  #updateShareDialogUrl() {
    if (this.hasShareDialogTarget) {
      const input = this.shareDialogTarget
        .querySelector("template[data-ruby-ui--dialog-target='content']")
        .content.querySelector("input[type='text']")

      input.setAttribute("value", window.location.origin + this.#newPagePath())
    }
  }

  #updateNativeShareUrl() {
    if (this.hasBridgeShareTarget) {
      this.bridgeShareTarget.setAttribute("data-bridge--share-url-value", window.location.origin + this.#newPagePath())
    }
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
