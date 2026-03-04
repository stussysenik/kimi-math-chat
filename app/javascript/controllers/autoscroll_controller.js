import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  connect() {
    this.scrollToBottom()
    this.observer = new MutationObserver(() => this.scrollToBottom())
    if (this.hasContainerTarget) {
      this.observer.observe(this.containerTarget, { childList: true, subtree: true })
    }

    // Clear input after form submission
    document.addEventListener("turbo:submit-end", this.clearInput.bind(this))
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
    document.removeEventListener("turbo:submit-end", this.clearInput.bind(this))
  }

  scrollToBottom() {
    if (this.hasContainerTarget) {
      requestAnimationFrame(() => {
        this.containerTarget.scrollTop = this.containerTarget.scrollHeight
      })
    }
  }

  clearInput(event) {
    const form = event.target
    const input = form.querySelector("#message-input")
    if (input) input.value = ""
  }
}
