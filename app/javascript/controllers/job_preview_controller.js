import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["jobsList", "previewPanel", "previewContent"]
  static values = {
    jobId: Number,
    isMobile: Boolean
  }

  connect() {
    this.checkScreenSize()
    window.addEventListener('resize', this.checkScreenSize.bind(this))
  }

  disconnect() {
    window.removeEventListener('resize', this.checkScreenSize.bind(this))
  }

  checkScreenSize() {
    this.isMobileValue = window.innerWidth < 1025
  }

  showPreview(event) {
    const jobId = event.params.jobId

    // Remove active state from all job cards
    this.clearActiveStates()

    // Add active state to clicked job card
    const clickedCard = event.currentTarget.closest('.job-card')
    if (clickedCard) {
      this.setActiveState(clickedCard)
    }

    if (this.isMobileValue) {
      // On mobile, navigate to full page
      window.location.href = `/job_offers/${jobId}`
    } else {
      // On desktop, show preview panel
      this.showDesktopPreview(jobId)
    }
  }

  showDesktopPreview(jobId) {
    // Adjust layout
    this.jobsListTarget.classList.remove('lg:w-full')
    this.jobsListTarget.classList.add('lg:w-1/2')
    this.previewPanelTarget.style.display = 'block'

    // Show loading state
    this.showLoadingState()

    // Fetch preview content
    fetch(`/job_offers/${jobId}/preview`)
      .then(response => {
        if (!response.ok) {
          throw new Error('Network response was not ok')
        }
        return response.text()
      })
      .then(html => {
        this.previewPanelTarget.innerHTML = html
      })
      .catch(error => {
        console.error('Error loading preview:', error)
        this.showErrorState()
      })
  }

  closePreview() {
    this.previewPanelTarget.style.display = 'none'
    this.jobsListTarget.classList.remove('lg:w-1/2')
    this.jobsListTarget.classList.add('lg:w-full')
    this.clearActiveStates()
  }

  clearActiveStates() {
    document.querySelectorAll('.job-card').forEach(card => {
      card.classList.remove('ring-2', 'ring-amber-500', 'bg-amber-50')
    })
  }

  setActiveState(card) {
    card.classList.add('ring-2', 'ring-amber-500', 'bg-amber-50')
  }

  showLoadingState() {
    this.previewPanelTarget.innerHTML = `
      <div class="h-full flex items-center justify-center">
        <div class="text-center">
          <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-amber-800 mx-auto mb-4"></div>
          <p class="text-gray-600">Loading job details...</p>
        </div>
      </div>
    `
  }

  showErrorState() {
    this.previewPanelTarget.innerHTML = `
      <div class="h-full flex items-center justify-center">
        <div class="text-center text-red-600">
          <svg class="mx-auto h-12 w-12 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
          </svg>
          <p class="text-lg font-medium mb-2">Error loading preview</p>
          <p class="text-sm">Please try again or view the full job details</p>
        </div>
      </div>
    `
  }
}
