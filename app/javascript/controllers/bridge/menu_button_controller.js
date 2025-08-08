import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

// Connects to data-controller="bridge--menu-button"
export default class extends BridgeComponent {
  static component = "menu-button"
  static values = {
    position: String,
  }

  connect() {
    super.connect()

    this.send("connect", { position: this.positionValue }, () => {
      if (document.querySelectorAll("#mobile-menu-content").length != 0) {
        document.querySelector("#mobile-menu-content > button").click()
      } else {
        document.querySelector("#mobile-menu > [data-action='click->ruby-ui--sheet#open']").click()
      }
    })
  }
}
