import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sync-value"
export default class extends Controller {
  static targets = ["source", "target"]

  sourceTargetConnected(source) {
    this.syncValueFromTargetToSource(source)

    source.addEventListener(source.dataset.syncEvent, (event) => {
      this.syncValueFromSourceToTarget(event.target)
    })
  }

  sourceTargetDisconnected(source) {
    source.removeEventListener(source.dataset.syncEvent, (event) => {
      this.syncValueFromSourceToTarget(event.target)
    })
  }

  syncValueFromSourceToTarget(source) {
    const target = this.findTargetBySyncId(source.dataset.syncId)

    if (target) {
      target.value = source.value
    }
  }

  syncValueFromTargetToSource(source) {
    const target = this.findTargetBySyncId(source.dataset.syncId)

    if (target) {
      source.value = target.value

      source.dispatchEvent(
        new InputEvent(source.dataset.syncEvent, { bubbles: true }),
      )
    }
  }

  findTargetBySyncId(syncId) {
    return this.targetTargets.find((target) => target.dataset.syncId === syncId)
  }
}
