import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.renderMath()
    this.observer = new MutationObserver(() => this.renderMath())
    this.observer.observe(this.element, { childList: true, subtree: true, characterData: true })
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  renderMath() {
    if (typeof renderMathInElement === "undefined") return

    requestAnimationFrame(() => {
      renderMathInElement(this.element, {
        delimiters: [
          { left: "$$", right: "$$", display: true },
          { left: "$", right: "$", display: false },
          { left: "\\(", right: "\\)", display: false },
          { left: "\\[", right: "\\]", display: true }
        ],
        throwOnError: false,
        trust: true
      })
    })
  }
}
