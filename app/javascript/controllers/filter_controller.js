import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    //console.log("Filter controller connected")
    
    // Listen for turbo:frame-render events
    document.addEventListener("turbo:frame-render", this.handleFrameRender)
  }
  
  disconnect() {
    // Clean up event listener
    document.removeEventListener("turbo:frame-render", this.handleFrameRender)
  }

  
  handleFrameRender = (event) => {
    // Check if it's our jobs frame
    if (event.target.id === "jobs") {
      // Use requestAnimationFrame to ensure browser has finished rendering
      requestAnimationFrame(() => {
        // Find the scroll-to-jobs controller and trigger scroll
        const jobsList = document.getElementById("jobs-list")
        if (jobsList) {
          const scrollToJobsController = this.application.getControllerForElementAndIdentifier(jobsList, "scroll-to-jobs")
          if (scrollToJobsController) {
            scrollToJobsController.scroll()
          }
        }
      })
    }
  }
  
  submit(event) {
    // Don't submit if the selected option is a disabled group label
    if (event.target.options && event.target.options[event.target.selectedIndex]?.disabled) {
      return
    }
    
    // Get the form element
    const form = this.element
    
    // Create form data and URL parameters
    const formData = new FormData(form)
    const params = new URLSearchParams(formData)
    
    // When filters change, reset to page 1
    params.delete('page')
    
    // Generate the new URL
    const newUrl = `${form.action}?${params.toString()}`
    
    // Do a full page visit for per_page changes and other filters
    if (event.target.id === 'per_page' || event.target.id === 'category' || event.target.id === 'region') {
      Turbo.visit(newUrl)
    } else {
      // Use frame updates for other changes
      Turbo.visit(newUrl, { frame: "jobs" })
      history.pushState({}, "", newUrl)
    }
  }
  
  paginate(event) {
    event.preventDefault()
    
    // Get the target URL from the link
    const url = event.currentTarget.href
    
    // Use frame updates for pagination
    Turbo.visit(url, { frame: "jobs" })
    
    // Update the browser history
    history.pushState({}, "", url)
  }

  reset(event) {
    event.preventDefault()

    // Clear all form fields
    const form = this.element
    form.reset()

    // Navigate to the base URL without any parameters
    const baseUrl = form.action
    Turbo.visit(baseUrl)
  }

  resetFromFrame(event) {
    // This method can be called from anywhere in the document
    event.preventDefault()

    // Find the filter form
    const form = document.querySelector('[data-controller*="filter"]')
    if (form) {
      // Clear all form fields
      form.reset()

      // Navigate to the base URL without any parameters
      const baseUrl = form.action
      Turbo.visit(baseUrl)
    }
  }
}