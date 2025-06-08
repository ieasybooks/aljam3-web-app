import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pages-controls"
export default class extends Controller {
  static targets = [ "iframe" ]

  firstPage() {
    this.iframeTarget.contentWindow.PDFViewerApplication.page = 1
  }

  previousPage() {
    this.iframeTarget.contentWindow.PDFViewerApplication.pdfViewer.previousPage()
  }

  nextPage() {
    this.iframeTarget.contentWindow.PDFViewerApplication.pdfViewer.nextPage()
  }

  lastPage() {
    this.iframeTarget.contentWindow.PDFViewerApplication.page = this.iframeTarget.contentWindow.PDFViewerApplication.pdfViewer.pagesCount
  }
}
