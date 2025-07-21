import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Keep old methods for backward compatibility
  setArabicLanguage() {
    console.log('Setting Arabic language')
    this.switchLanguage('ar')
  }

  setEnglishLanguage() {
    console.log('Setting English language')
    this.switchLanguage('en')
  }

  switchToAr() {
    console.log('Switching to Arabic language')
    this.switchLanguage('ar')
  }

  switchToEn() {
    console.log('Switching to English language')
    this.switchLanguage('en')
  }

  // New method that gets locale from data attribute
  switchLanguage(event) {
    // If called directly with a string parameter (backward compatibility)
    if (typeof event === 'string') {
      console.log('Switching to locale:', event)
      this.performLanguageSwitch(event)
      return
    }

    // If called from click event, get locale from data attribute
    const locale = event.currentTarget.dataset.languageToggleLocaleParam
    console.log('Switching to locale from button:', locale)
    
    if (locale) {
      this.performLanguageSwitch(locale)
    } else {
      console.error('No locale found in data attribute')
    }
  }

  performLanguageSwitch(locale) {
    console.log('Performing language switch to:', locale)
    
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