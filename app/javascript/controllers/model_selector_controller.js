import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select"]
  static values = { url: String }

  change() {
    const modelId = this.selectTarget.value
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content

    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: JSON.stringify({ model_id: modelId })
    })
  }
}
