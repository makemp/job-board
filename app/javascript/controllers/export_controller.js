import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="export"
export default class extends Controller {
  static targets = ["fromDate", "toDate", "jobType", "sourceType", "platform", "limit", "output", "exportButton"]

  connect() {
    this.setDefaultDates()
  }

  setDefaultDates() {
    const today = new Date()
    const sevenDaysAgo = new Date(today.getTime() - (7 * 24 * 60 * 60 * 1000))

    this.fromDateTarget.value = this.formatDate(sevenDaysAgo)
    this.toDateTarget.value = this.formatDate(today)
  }

  formatDate(date) {
    return date.toISOString().split('T')[0]
  }

  async export() {
    const fromDate = this.fromDateTarget.value
    const toDate = this.toDateTarget.value
    const jobType = this.jobTypeTarget.value
    const sourceType = this.sourceTypeTarget.value
    const platform = this.platformTarget.value
    const limit = this.limitTarget.value

    if (!fromDate || !toDate) {
      alert("Please select both from and to dates")
      return
    }

    if (new Date(fromDate) > new Date(toDate)) {
      alert("From date cannot be later than to date")
      return
    }

    if (!limit || limit < 1 || limit > 10000) {
      alert("Please enter a valid limit between 1 and 10000")
      return
    }

    this.exportButtonTarget.disabled = true
    this.exportButtonTarget.textContent = "Generating..."

    try {
      const response = await fetch('/amdg/exports/generate', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          from_date: fromDate,
          to_date: toDate,
          job_offer_type: jobType,
          source_type: sourceType,
          platform: platform,
          limit: parseInt(limit)
        })
      })

      const data = await response.json()

      if (response.ok) {
        this.outputTarget.value = data.markdown
        this.outputTarget.style.height = 'auto'
        this.outputTarget.style.height = this.outputTarget.scrollHeight + 'px'
      } else {
        alert(data.error || "An error occurred while generating the export")
      }
    } catch (error) {
      console.error('Export error:', error)
      alert("An error occurred while generating the export")
    } finally {
      this.exportButtonTarget.disabled = false
      this.exportButtonTarget.textContent = "Export"
    }
  }

  copyToClipboard(event) {
    if (!this.outputTarget.value) {
      alert("No content to copy")
      return
    }

    const button = event.currentTarget

    // Try modern clipboard API first
    if (navigator.clipboard) {
      navigator.clipboard.writeText(this.outputTarget.value)
        .then(() => {
          this.showCopySuccess(button)
        })
        .catch((err) => {
          console.error('Clipboard API failed:', err)
          this.fallbackCopyToClipboard(button)
        })
    } else {
      // Fallback for older browsers
      this.fallbackCopyToClipboard(button)
    }
  }

  fallbackCopyToClipboard(button) {
    try {
      // Select the textarea content
      this.outputTarget.select()
      this.outputTarget.setSelectionRange(0, 99999) // For mobile devices

      // Try to copy using execCommand
      const successful = document.execCommand('copy')

      if (successful) {
        this.showCopySuccess(button)
      } else {
        this.showCopyError(button)
      }
    } catch (err) {
      console.error('Fallback copy failed:', err)
      this.showCopyError(button)
    }
  }

  showCopySuccess(button) {
    const originalText = button.textContent
    const originalBgColor = button.classList.contains('bg-green-600') ? 'bg-green-600' : 'bg-green-700'

    // Remove existing background colors and add success color
    button.classList.remove('bg-green-600', 'bg-green-700', 'hover:bg-green-700')
    button.classList.add('bg-green-800')
    button.textContent = "Copied!"

    setTimeout(() => {
      button.textContent = originalText
      button.classList.remove('bg-green-800')
      button.classList.add(originalBgColor, 'hover:bg-green-700')
    }, 2000)
  }

  showCopyError(button) {
    const originalText = button.textContent

    button.classList.remove('bg-green-600', 'bg-green-700')
    button.classList.add('bg-red-600')
    button.textContent = "Copy Failed"

    setTimeout(() => {
      button.textContent = originalText
      button.classList.remove('bg-red-600')
      button.classList.add('bg-green-600', 'hover:bg-green-700')
    }, 2000)

    // Also show an alert with instructions
    alert("Automatic copy failed. Please manually select all text in the output field and copy it (Ctrl+C or Cmd+C).")
  }
}
