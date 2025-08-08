import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

// Connects to data-controller="bridge--share"
export default class extends BridgeComponent {
  static component = "share"
  static values = {
    url: { type: String, default: "" },
    text: { type: String, default: "" },
  }

  connect() {
    super.connect()

    let url = window.location.href

    if (this.urlValue.length > 0) {
      url = this.urlValue
    }

    if (this.textValue.length > 0) {
      this.send("connect", { url, text: `\n\n${this.textValue}` })
    } else {
      this.send("connect", { url })
    }
  }
}
