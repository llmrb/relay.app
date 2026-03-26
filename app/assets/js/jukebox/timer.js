const Timer = function() {
  const self = Object.create(null)
  
  let interval = null
  let startTime = null
  let currentStatus = ""
  let timerElement = null

  const getParent = () => {
    return document.getElementById("chatbot-status")
  }

  const getStatusSpan = (parent) => {
    return parent?.querySelector(".status-value")
  }

  const createTimerElement = () => {
    const timer = document.createElement("span")
    timer.className = "timer-value ml-2 inline-flex items-center gap-1 rounded-full bg-theme-accent-soft px-2 py-0.5 text-xs font-medium tracking-tight text-theme-accent-strong transition-all duration-200"
    return timer
  }

  const updateTimer = (elapsedSeconds) => {
    if (!timerElement) return
    
    // Add subtle pulse animation for the first few seconds
    if (elapsedSeconds <= 3) {
      timerElement.classList.add("animate-pulse")
    } else {
      timerElement.classList.remove("animate-pulse")
    }
    
    // Update text with appropriate formatting
    timerElement.textContent = `${elapsedSeconds}s`
    
    // Add tooltip for longer durations
    if (elapsedSeconds >= 10) {
      timerElement.title = `Running for ${elapsedSeconds} seconds`
    } else {
      timerElement.removeAttribute("title")
    }
  }

  const attachTimer = (statusSpan) => {
    if (!statusSpan || timerElement) return
    
    timerElement = createTimerElement()
    
    // Insert timer after the status text
    const wrapper = document.createElement("span")
    wrapper.className = "inline-flex items-center"
    
    // Get the original text
    const originalText = statusSpan.textContent.replace(/\s*\(\d+s\)$/, "")
    
    // Create text node for status
    const textNode = document.createTextNode(originalText)
    
    // Clear and rebuild
    statusSpan.textContent = ""
    wrapper.appendChild(textNode)
    wrapper.appendChild(timerElement)
    statusSpan.appendChild(wrapper)
  }

  const detachTimer = () => {
    if (!timerElement) return
    
    const statusSpan = getStatusSpan(getParent())
    if (statusSpan && timerElement.parentNode) {
      // Remove the timer element
      timerElement.parentNode.remove()
      
      // Restore original text
      const originalText = currentStatus || "Ready"
      statusSpan.textContent = originalText
    }
    
    timerElement = null
  }

  self.start = (statusText) => {
    if (interval) {
      clearInterval(interval)
    }
    
    currentStatus = statusText.replace(/\s*\(\d+s\)$/, "")
    startTime = Date.now()
    
    const parent = getParent()
    const statusSpan = getStatusSpan(parent)
    
    if (!statusSpan) return
    
    // Attach timer element
    attachTimer(statusSpan)
    
    interval = setInterval(() => {
      const elapsedSeconds = Math.floor((Date.now() - startTime) / 1000)
      updateTimer(elapsedSeconds)
    }, 1000)
    
    // Initial update
    updateTimer(0)
  }

  self.stop = () => {
    if (interval) {
      clearInterval(interval)
      interval = null
    }
    
    detachTimer()
    startTime = null
    currentStatus = ""
  }

  self.handle = (parent) => {
    const statusSpan = getStatusSpan(parent)
    if (!statusSpan) return
    
    const statusText = statusSpan.textContent.trim()
    
    if (statusText.startsWith("Thinking") || statusText.startsWith("Running")) {
      self.start(statusText)
    } else {
      self.stop()
    }
  }

  return self
}

export { Timer }