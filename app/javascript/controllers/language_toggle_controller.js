import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Keep old methods for backward compatibility
  setArabicLanguage() {
    this.switchLanguage('ar')
  }

  setEnglishLanguage() {
    this.switchLanguage('en')
  }

  switchToAr() {
    this.switchLanguage('ar')
  }

  switchToEn() {
    this.switchLanguage('en')
  }

  // New method that gets locale from data attribute
  switchLanguage(event) {
    // If called directly with a string parameter (backward compatibility)
    if (typeof event === 'string') {
      this.performLanguageSwitch(event)
      return
    }

    // If called from click event, get locale from data attribute
    const locale = event.currentTarget.dataset.languageToggleLocaleParam
    
    if (locale) {
      this.performLanguageSwitch(locale)
    } else {
      console.error('No locale found in data attribute')
    }
  }

  performLanguageSwitch(locale) {
    
    // Send request to Rails to switch locale
    fetch('/switch_locale', {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      },
      body: JSON.stringify({ locale: locale })
    }).then(() => {
      // Reload the page to apply the new locale
      window.location.reload()
    }).catch(error => {
      console.error('Error switching language:', error)
    })
  }
} 