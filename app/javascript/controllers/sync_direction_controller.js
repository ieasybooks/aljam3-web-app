import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sync-direction"
export default class extends Controller {
  static values = {
    rtlLanguages: Array,
    ltrLanguages: Array,
  }

  connect() {
    const htmlElement = document.documentElement
    const url = window.location.href

    if (this.#isRtlLanguage(url) && htmlElement.getAttribute("dir") !== "rtl") {
      htmlElement.setAttribute("dir", "rtl")
    } else if (this.#isLtrLanguage(url) && htmlElement.getAttribute("dir") !== "ltr") {
      htmlElement.setAttribute("dir", "ltr")
    }
  }

  #isRtlLanguage(url) {
    for (const language of this.rtlLanguagesValue) {
      if (url.endsWith(`/${language}`) || url.includes(`/${language}/`)) {
        return true
      }
    }

    return false
  }

  #isLtrLanguage(url) {
    for (const language of this.ltrLanguagesValue) {
      if (url.endsWith(`/${language}`) || url.includes(`/${language}/`)) {
        return true
      }
    }

    return false
  }
}
