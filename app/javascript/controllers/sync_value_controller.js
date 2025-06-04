import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sync-value"
export default class extends Controller {
  static targets = ["source", "target"]

  sourceTargetConnected(target) {
    target.addEventListener(target.dataset.syncEvent, (event) => {
      this.syncValue(event.target)
    })
  }

  syncValue(source) {
    const id = source.dataset.syncId

    const matchingTargets = this.targetTargets.filter(target => 
      target.dataset.syncId === id
    )

    matchingTargets.forEach(target => {
      if (target !== source) {
        target.value = source.value
      }
    })
  }
}
