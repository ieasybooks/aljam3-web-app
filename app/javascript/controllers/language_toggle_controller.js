import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  setArabicLanguage() {
    console.log('Setting Arabic language')
    this.switchLanguage('ar')
  }

  setEnglishLanguage() {
    console.log('Setting English language')
    this.switchLanguage('en')
  }

  switchLanguage(locale) {
    console.log('Switching to locale:', locale)
    
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