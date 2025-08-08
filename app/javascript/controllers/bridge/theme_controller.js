import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

// Connects to data-controller="bridge--theme"
export default class extends BridgeComponent {
  static component = "theme"

  connect() {
    super.connect()

    const theme = localStorage.theme || (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light")

    this.send("updateTheme", { theme })
  }

  toggleLight() {
    this.send("updateTheme", { theme: "light" }, () => {})
  }

  toggleDark() {
    this.send("updateTheme", { theme: "dark" }, () => {})
  }
}
