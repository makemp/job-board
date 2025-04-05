import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Filter controller connected")
    
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
        // Get the top position of the filter section
        const filterSection = document.querySelector(".bg-amber-100")
        if (filterSection) {
          const filterBottom = filterSection.offsetTop + filterSection.offsetHeight
          window.scrollTo({
            top: filterBottom - 20, // Scroll to just below the filters
            behavior: "smooth"
          })
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
    
    // Generate the new URL
    const newUrl = `${form.action}?${params.toString()}`
    
    // Submit the form via Turbo - use replace action to ensure full replacement
    Turbo.visit(newUrl, { frame: "jobs", action: "replace" })
    
    // Update the browser history so the URL reflects the filter state
    history.pushState({}, "", newUrl)
  }
  
  paginate(event) {
    event.preventDefault()
    
    // Get the target URL from the link
    const url = event.currentTarget.href
    
    // Visit the URL with Turbo - use replace action to ensure full replacement
    Turbo.visit(url, { frame: "jobs", action: "replace" })
    
    // Update the browser history
    history.pushState({}, "", url)
  }
}