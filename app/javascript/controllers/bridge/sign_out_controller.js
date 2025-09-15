import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

// Connects to data-controller="bridge--sign-out"
export default class extends BridgeComponent {
  static component = "sign-out"

  static values = {
    path: String,
  }

  signOut(event) {
    event.preventDefault()
    event.stopImmediatePropagation()

    const path = this.pathValue
    this.send("signOut", { path }, () => {})
  }
}
