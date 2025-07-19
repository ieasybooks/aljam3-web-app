import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="text-rotation"
export default class extends Controller {
  static values = {
    strings: {
      type: Array,
      default: [],
    },
    interval: {
      type: Number,
      default: 2500,
    },
    fadeSpeed: {
      type: Number,
      default: 500,
    },
  };

  connect() {
    this.currentIndex = 0;
    this.intervalId = null;

    if (this.stringsValue.length > 0) {
      this.element.textContent = this.stringsValue[0];
      this.startRotation();
    }
  }

  disconnect() {
    this.stopRotation();
  }

  startRotation() {
    if (this.stringsValue.length <= 1) return;

    this.intervalId = setInterval(() => {
      this.rotateText();
    }, this.intervalValue);
  }

  stopRotation() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }

  rotateText() {
    // Fade out current text
    this.element.style.opacity = "0";
    this.element.style.transition = `opacity ${this.fadeSpeedValue}ms ease-in-out`;

    setTimeout(() => {
      // Update to next string
      this.currentIndex = (this.currentIndex + 1) % this.stringsValue.length;
      this.element.textContent = this.stringsValue[this.currentIndex];

      // Fade in new text
      this.element.style.opacity = "1";
    }, this.fadeSpeedValue);
  }
}
