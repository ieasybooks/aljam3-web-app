import { Controller } from "@hotwired/stimulus"

const SIZE_TO_CLASS = {
  1: "text-xs",
  2: "text-sm",
  3: "text-base",
  4: "text-lg",
  5: "text-xl",
  6: "text-2xl",
  7: "text-3xl",
  8: "text-4xl",
  9: "text-5xl"
}

// Connects to data-controller="txt-content"
export default class extends Controller {
  static targets = [ "content", "copyButton" ]
  static values = {
    copyButtonDoneStatus: String
  }

  connect() {
    this.currentContentSize = parseInt(localStorage.getItem("txt-content-size")) || 3

    this.contentTarget.classList.add(SIZE_TO_CLASS[this.currentContentSize])
  }

  copy() {
    navigator.clipboard.writeText(this.contentTarget.textContent)

    const oldInnerHTML = this.copyButtonTarget.innerHTML

    this.copyButtonTarget.setAttribute("disabled", true)
    this.copyButtonTarget.innerHTML = this.copyButtonDoneStatusValue

    setTimeout(() => {
      this.copyButtonTarget.innerHTML = oldInnerHTML
      this.copyButtonTarget.removeAttribute("disabled")
    }, 1000)
  }

  textSizeIncrease() {
    this.currentContentSize = this.currentContentSize + 1

    if (this.currentContentSize > 9) {
      this.currentContentSize = 9
    }

    this.contentTarget.classList.remove(SIZE_TO_CLASS[this.currentContentSize - 1])
    this.contentTarget.classList.add(SIZE_TO_CLASS[this.currentContentSize])

    localStorage.setItem("txt-content-size", this.currentContentSize)
  }

  textSizeDecrease() {
    this.currentContentSize = this.currentContentSize - 1

    if (this.currentContentSize < 1) {
      this.currentContentSize = 1
    }

    this.contentTarget.classList.remove(SIZE_TO_CLASS[this.currentContentSize + 1])
    this.contentTarget.classList.add(SIZE_TO_CLASS[this.currentContentSize])

    localStorage.setItem("txt-content-size", this.currentContentSize)
  }
}
