import { Controller } from "@hotwired/stimulus"

import TomSelect from "tom-select"
import { autoUpdate, computePosition, flip, offset } from "@floating-ui/dom"

const ARABIC_NORMALIZATION_MAP = { أ: "ا", إ: "ا", آ: "ا", ة: "ه", ي: "ى" }
const ARABIC_NORMALIZATION_REGEX = /[أإآةي]/g
const ARABIC_DIACRITICS = /[ًٌٍَُِّْ]/g

function normalizeArabicText(text) {
  return text
    .replace(
      ARABIC_NORMALIZATION_REGEX,
      (char) => ARABIC_NORMALIZATION_MAP[char],
    )
    .replace(ARABIC_DIACRITICS, "")
}

// Connects to data-controller="tom-select"
export default class extends Controller {
  static values = {
    url: String,
    plugins: Array,
    valueField: String,
    labelField: String,
    options: Array,
    items: Array,
    searchField: Array,
    maxItems: Number,
    preload: Boolean,
    noResults: String,
    defaultValueSource: String,
  }

  connect() {
    const url = `${this.urlValue}.json`
    const defaultValueSourceValue = this.defaultValueSourceValue

    this.select = new TomSelect(this.element, {
      plugins: this.pluginsValue,
      valueField: this.valueFieldValue,
      labelField: this.labelFieldValue,
      options: this.optionsValue,
      items: this.itemsValue,
      searchField: this.searchFieldValue,
      maxItems: this.maxItemsValue,
      preload: this.preloadValue,
      highlight: false,
      render: {
        no_results: (_data, _escape) => {
          return `<div class="no-results text-center">${this.noResultsValue}</div>`
        },
        option: (data, escape) => {
          return (
            '<div class="px-2! py-1.5! text-sm! rounded-sm! outline-none! transition-colors! cursor-pointer! hover:bg-accent! hover:text-accent-foreground! focus:bg-accent! focus:text-accent-foreground! aria-selected:bg-accent! aria-selected:text-accent-foreground!">' +
            escape(data.name) +
            "</div>"
          )
        },
      },
      load: function (_query, callback) {
        var self = this

        if (self.loading > 1) {
          callback()

          return
        }

        fetch(url)
          .then((response) => response.json())
          .then((json) => {
            callback(json)

            self.settings.load = null
          })
          .catch(() => {
            callback()
          })
      },
      score: function (search) {
        var score = this.getScoreFunction(normalizeArabicText(search))

        return function (item) {
          item.name = normalizeArabicText(item.name)

          return score(item)
        }
      },
      onInitialize() {
        const referenceEl = this.control
        const floatingEl = this.dropdown

        this.cleanup = autoUpdate(referenceEl, floatingEl, () => {
          computePosition(referenceEl, floatingEl, {
            placement: "bottom-start",
            middleware: [
              offset(({ placement }) => {
                return placement.startsWith("top") ? 8 : 0
              }),
              flip(),
            ],
          }).then(({ x, y }) => {
            Object.assign(floatingEl.style, {
              position: "absolute",
              left: `${x}px`,
              top: `${y}px`,
            })
          })
        })
      },
      onDropdownClose() {
        if (this.cleanup) {
          this.cleanup()
        }
      },
      onLoad() {
        this.setValue(document.querySelector(defaultValueSourceValue).value)
      },
    })
  }

  disconnect() {
    if (this.select) {
      this.select.destroy()
    }
  }
}
