const Timer = function() {
  const self = Object.create(null)
  self.statusEl = document.getElementById("chatbot-status")
  self.statusSpan = self.statusEl?.querySelector(".font-medium.text-zinc-100")
  
  let interval = null
  let startTime = null
  let currentStatus = ""

  const update = (text) => {
    if (self.statusSpan) {
      self.statusSpan.textContent = text
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
      update(`${currentStatus} (${elapsedSeconds}s)`)
    }, 1000)
    update(`${currentStatus} (0s)`)
  }

  self.stop = () => {
    if (interval) {
      clearInterval(interval)
      interval = null
    }
    startTime = null
    currentStatus = ""
  }

  self.handle = (statusElement) => {
    const span = statusElement.querySelector(".font-medium.text-zinc-100")
    if (!span) return
    const statusText = span.textContent.trim()
    if (statusText.startsWith("Thinking") || statusText.startsWith("Running")) {
      self.start(statusText)
    } else {
      self.stop()
    }
  }

  return self
}

export { Timer }