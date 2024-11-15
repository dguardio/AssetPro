import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "fileInput" ]

  triggerFileInput(event) {
    this.fileInputTarget.click()
  }

  submit(event) {
    this.element.submit()
  }
} 