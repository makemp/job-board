import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["jobsList", "previewPanel", "previewContent", "mobilePreview"]
  static values = {
    jobId: Number,
    isMobile: Boolean
  }

  connect() {
    this.checkScreenSize()
    window.addEventListener('resize', this.checkScreenSize.bind(this))

    // Store reference to this controller instance globally for mobile close button
    window.jobPreviewController = this

    // Create mobile preview element if it doesn't exist
    this.createMobilePreviewElement()
  }

  disconnect() {
    window.removeEventListener('resize', this.checkScreenSize.bind(this))
  }

  checkScreenSize() {
    this.isMobileValue = window.innerWidth < 1025
  }

  createMobilePreviewElement() {
    // Check if mobile preview already exists in DOM
    let existingPreview = document.querySelector('[data-job-preview-target="mobilePreview"]')
    if (!existingPreview) {
      const mobilePreview = document.createElement('div')
      mobilePreview.setAttribute('data-job-preview-target', 'mobilePreview')
      mobilePreview.className = 'fixed inset-0 z-50 transform translate-x-full transition-transform duration-300 ease-in-out lg:hidden'
      mobilePreview.innerHTML = `
        <div class="h-full bg-white flex flex-col">
          <!-- Fixed header with close button and actions -->
          <div class="flex-shrink-0 bg-white border-b border-gray-200 px-4 py-3 flex items-center justify-between sticky top-0 z-10 shadow-sm">
            <button onclick="window.jobPreviewController.closeMobilePreview()"
                    class="flex items-center justify-center h-10 w-10 rounded-full hover:bg-gray-100 transition-colors duration-200">
              <svg class="h-6 w-6 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
              </svg>
            </button>
            <div class="flex items-center space-x-3">
              <button data-controller="copy-url"
                      data-action="click->copy-url#copy"
                      data-copy-url-target="button"
                      type="button"
                      class="flex items-center justify-center h-10 w-10 bg-amber-800 hover:bg-amber-700 text-white rounded-full shadow transition-colors duration-300">
                <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"/>
                </svg>
              </button>
              <a href="#" target="_blank" rel="noopener noreferrer"
                 class="flex items-center justify-center h-10 w-10 bg-amber-800 hover:bg-amber-700 text-white rounded-full shadow transition-colors duration-300"
                 data-job-preview-target="newTabLink">
                <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/>
                </svg>
              </a>
            </div>
          </div>
          <!-- Job title header for mobile -->
          <div class="flex-shrink-0 bg-amber-50 px-4 py-3 border-b border-amber-200">
            <h1 class="text-xl font-bold text-amber-900 truncate" id="mobile-job-title">
              <!-- Title will be set dynamically -->
            </h1>
            <p class="text-sm text-amber-700 truncate" id="mobile-company-name">
              <!-- Company name will be set dynamically -->
            </p>
          </div>
          <!-- Scrollable content -->
          <div class="flex-1 overflow-y-auto" data-job-preview-target="mobileContent">
            <!-- Content will be loaded here -->
          </div>
        </div>
      `
      document.body.appendChild(mobilePreview)

      // Force Stimulus to recognize the new targets
      this.application.start()
    }
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
      // Show mobile slide-out preview
      this.showMobilePreview(jobId)
    } else {
      // On desktop, show preview panel
      this.showDesktopPreview(jobId)
    }
  }

  showMobilePreview(jobId) {
    // Get mobile preview element directly from DOM if target is not available
    const mobilePreview = this.hasMobilePreviewTarget ?
      this.mobilePreviewTarget :
      document.querySelector('[data-job-preview-target="mobilePreview"]')

    if (!mobilePreview) {
      console.error('Mobile preview element not found')
      return
    }

    const mobileContent = mobilePreview.querySelector('[data-job-preview-target="mobileContent"]')

    // Show loading state
    mobileContent.innerHTML = this.getLoadingHTML()

    // Update copy URL and new tab link
    const copyButton = mobilePreview.querySelector('[data-copy-url-target="button"]')
    const newTabLink = mobilePreview.querySelector('[data-job-preview-target="newTabLink"]')

    if (copyButton) {
      copyButton.setAttribute('data-copy-url-url-value', `/job_offers/${jobId}`)
    }

    if (newTabLink) {
      newTabLink.href = `/job_offers/${jobId}`
    }

    // Slide in the preview
    mobilePreview.classList.remove('translate-x-full')
    document.body.style.overflow = 'hidden' // Prevent background scrolling

    // Fetch preview content
    fetch(`/job_offers/${jobId}/preview`)
      .then(response => {
        if (!response.ok) {
          throw new Error('Network response was not ok')
        }
        return response.text()
      })
      .then(html => {
        // Extract content from the preview HTML (remove the wrapper div and header)
        const tempDiv = document.createElement('div')
        tempDiv.innerHTML = html

        // Get the content inside the preview, but adapt it for mobile
        const previewContent = tempDiv.querySelector('.h-full > .p-6')
        if (previewContent) {
          // Extract job title and company name from the header before removing it
          const headerElement = previewContent.querySelector('.flex.justify-between.items-start.mb-6')
          if (headerElement) {
            const titleElement = headerElement.querySelector('h1')
            const companyElement = headerElement.querySelector('p')

            // Update mobile header with job title and company name
            const mobileTitleElement = document.getElementById('mobile-job-title')
            const mobileCompanyElement = document.getElementById('mobile-company-name')

            if (mobileTitleElement && titleElement) {
              mobileTitleElement.textContent = titleElement.textContent.trim()
            }

            if (mobileCompanyElement && companyElement) {
              mobileCompanyElement.textContent = companyElement.textContent.trim()
            }

            // Remove the desktop header since we have our own mobile header
            headerElement.remove()
          }

          mobileContent.innerHTML = `<div class="p-4">${previewContent.innerHTML}</div>`
        } else {
          mobileContent.innerHTML = `<div class="p-4">${html}</div>`
        }
      })
      .catch(error => {
        console.error('Error loading mobile preview:', error)
        mobileContent.innerHTML = this.getErrorHTML()
      })
  }

  closeMobilePreview() {
    // Get mobile preview element directly from DOM if target is not available
    const mobilePreview = this.hasMobilePreviewTarget ?
      this.mobilePreviewTarget :
      document.querySelector('[data-job-preview-target="mobilePreview"]')

    if (mobilePreview) {
      mobilePreview.classList.add('translate-x-full')
      document.body.style.overflow = '' // Restore background scrolling
    }
    this.clearActiveStates()
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
    this.previewPanelTarget.innerHTML = this.getLoadingHTML()
  }

  showErrorState() {
    this.previewPanelTarget.innerHTML = this.getErrorHTML()
  }

  getLoadingHTML() {
    return `
      <div class="h-full flex items-center justify-center">
        <div class="text-center">
          <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-amber-800 mx-auto mb-4"></div>
          <p class="text-gray-600">Loading job details...</p>
        </div>
      </div>
    `
  }

  getErrorHTML() {
    return `
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
