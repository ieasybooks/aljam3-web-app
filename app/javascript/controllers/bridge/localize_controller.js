import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

// Connects to data-controller="bridge--localize"
export default class extends BridgeComponent {
  static component = "localize"
  static values = {
    translations: Object,
  }

  connect() {
    super.connect()

    this.send("connect", {
      translations: this.translationsValue,
      locale: document.documentElement.lang,
      direction: document.documentElement.dir,
    })
  }
}
