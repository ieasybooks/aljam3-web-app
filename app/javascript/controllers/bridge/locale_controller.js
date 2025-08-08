import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

// Connects to data-controller="bridge--locale"
export default class extends BridgeComponent {
  static component = "locale"

  connect() {
    super.connect()

    if (window.location.pathname.length > 3) {
      return
    }

    const storageLocale = localStorage.locale
    const urlLocale = this.#getUrlLocale()

    if (!urlLocale && storageLocale !== "ar") {
      this.send("updateLocale", { locale: storageLocale })
    }

    localStorage.locale = urlLocale || storageLocale || "ar"
  }

  #getUrlLocale() {
    const pathName = window.location.pathname

    if (pathName.length !== 3) {
      return undefined
    }

    return pathName.substring(1, 3)
  }
}
