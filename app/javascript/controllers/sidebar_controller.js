import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "content", "button"]

  connect() {
    // Initialize sidebar state from localStorage
    const sidebarOpen = localStorage.getItem('sidebarOpen') !== 'false'
    this.toggleSidebar(sidebarOpen)
  }

  toggle() {
    const isVisible = !this.sidebarTarget.classList.contains('d-none')
    this.toggleSidebar(!isVisible)
    localStorage.setItem('sidebarOpen', !isVisible)
  }

  toggleSidebar(show) {
    if (show) {
      this.sidebarTarget.classList.remove('d-none')
      this.contentTarget.classList.remove('expanded')
      this.buttonTarget.classList.add('is-active')
    } else {
      this.sidebarTarget.classList.add('d-none')
      this.contentTarget.classList.add('expanded')
      this.buttonTarget.classList.remove('is-active')
    }
  }
} 