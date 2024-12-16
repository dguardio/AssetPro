import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["secretMask", "secretValue", "visibilityIcon", "clientId"]

  toggleSecretVisibility() {
    this.secretMaskTarget.classList.toggle('d-none')
    this.secretValueTarget.classList.toggle('d-none')
    this.visibilityIconTarget.textContent = 
      this.secretValueTarget.classList.contains('d-none') ? 'visibility' : 'visibility_off'
  }

  copySecret() {
    this.copyToClipboard(this.secretValueTarget.textContent)
  }

  copyClientId() {
    this.copyToClipboard(this.clientIdTarget.textContent)
  }

  async copyToClipboard(text) {
    try {
      await navigator.clipboard.writeText(text)
      this.showToast('success', 'Copied to clipboard!')
    } catch (err) {
      this.showToast('error', 'Failed to copy')
    }
  }

  showToast(icon, title) {
    Swal.fire({
      toast: true,
      position: 'top-end',
      icon: icon,
      title: title,
      showConfirmButton: false,
      timer: 3000,
      timerProgressBar: true
    })
  }
} 