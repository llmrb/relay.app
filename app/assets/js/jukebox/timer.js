const Timer = function() {
  const self = Object.create(null)
  let interval = null
  let startTime = null
  let currentStatus = ""

  const updateDisplay = (text) => {
    const statusElement = document.getElementById("chatbot-status")
    if (!statusElement) return
    
    const statusSpan = statusElement.querySelector(".font-medium.text-zinc-100")
    if (statusSpan) {
      statusSpan.textContent = text
    }
  }

  self.start = (statusText) => {
    if (interval) {
      clearInterval(interval)
    }
    
    currentStatus = statusText.replace(/\s*\(\d+s\)$/, "")
    startTime = Date.now()
    
    interval = setInterval(() => {
      const elapsedSeconds = Math.floor((Date.now() - startTime) / 1000)
      updateDisplay(`${currentStatus} (${elapsedSeconds}s)`)
    }, 1000)
    
    updateDisplay(`${currentStatus} (0s)`)
  }

  self.stop = () => {
    if (interval) {
      clearInterval(interval)
      interval = null
    }
    startTime = null
    currentStatus = ""
  }

  self.handleStatusUpdate = (statusElement) => {
    const statusSpan = statusElement.querySelector(".font-medium.text-zinc-100")
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