import { Controller } from "@hotwired/stimulus";

import { get } from "@rails/request.js";

// Connects to data-controller="pdf-viewer"
export default class extends Controller {
  static targets = ["iframe", "content", "progress"];
  static values = {
    bookId: Number,
    fileId: Number,
    currentPage: Number,
    skeleton: String,
    totalPages: Number,
  };

  connect() {
    this.internalCurrentPage = this.currentPageValue;
    this.currentAbortController = null;
    this.debounceTimeout = null;

    this.#registerPageChangingEvent();
  }

  disconnect() {
    this.#cleanup();
  }

  currentPageValueChanged() {
    this.#cleanup();

    this.debounceTimeout = setTimeout(() => {
      this.progressTarget.style.width = `${(this.currentPageValue / this.totalPagesValue) * 100}%`;

      if (this.currentPageValue === this.internalCurrentPage) {
        return;
      }

      this.#fetchPageContent();

      this.internalCurrentPage = this.currentPageValue;
    }, 100);
  }

  #registerPageChangingEvent() {
    if (this.iframeTarget.contentWindow?.PDFViewerApplication?.eventBus) {
      this.#hideNonFunctionalButtons();

      this.iframeTarget.contentWindow.PDFViewerApplication.eventBus._on(
        "pagechanging",
        (event) => {
          this.currentPageValue = event.pageNumber;
        },
      );
    } else {
      setTimeout(() => this.#registerPageChangingEvent(), 100);
    }
  }

  #hideNonFunctionalButtons() {
    this.iframeTarget.contentWindow.document
      .querySelector("#viewFind")
      .classList.add("hidden");

    this.iframeTarget.contentWindow.document
      .querySelector("#viewAttachments")
      .classList.add("hidden");
    this.iframeTarget.contentWindow.document
      .querySelector("#viewLayers")
      .classList.add("hidden");

    this.iframeTarget.contentWindow.document
      .querySelector("#secondaryOpenFile")
      .classList.add("hidden");
    this.iframeTarget.contentWindow.document
      .querySelector("#secondaryPrint")
      .classList.add("hidden");

    this.iframeTarget.contentWindow.document
      .querySelector("#viewBookmark")
      .classList.add("hidden");

    this.iframeTarget.contentWindow.document
      .querySelector("#cursorToolButtons")
      .classList.add("hidden");
    this.iframeTarget.contentWindow.document
      .querySelector("#cursorToolButtons + .horizontalToolbarSeparator")
      .classList.add("hidden");

    this.iframeTarget.contentWindow.document
      .querySelector("#scrollModeButtons")
      .classList.add("hidden");
    this.iframeTarget.contentWindow.document
      .querySelector("#scrollModeButtons + .horizontalToolbarSeparator")
      .classList.add("hidden");
  }

  async #fetchPageContent() {
    this.currentAbortController = new AbortController();

    try {
      this.contentTarget.innerHTML = this.skeletonValue;

      await get(this.#newPagePath(), {
        responseKind: "turbo-stream",
        signal: this.currentAbortController.signal,
      });

      history.replaceState(null, "", this.#newPagePath());
    } catch (error) {
      // Ignore AbortError - it means we cancelled the request intentionally
      if (error.name !== "AbortError") {
        console.error("Error fetching page content:", error);
      }
    }
  }

  #newPagePath() {
    return `/${this.bookIdValue}/${this.fileIdValue}/${this.currentPageValue}`;
  }

  #cleanup() {
    if (this.currentAbortController) {
      this.currentAbortController.abort();
    }

    if (this.debounceTimeout) {
      clearTimeout(this.debounceTimeout);
    }
  }
}
