const Timer = function() {
  const self = Object.create(null)
  
  let interval = null
  let startTime = null
  let currentStatus = ""

  const getParent = () => {
    return document.getElementById("chatbot-status")
  }

  const getSpan = (parent) => {
    return parent?.querySelector(".font-medium.text-zinc-100")
  }

  const update = (text) => {
    const parent = getParent()
    const span = getSpan(parent)
    if (span) {
      span.textContent = text
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

  self.handle = (parent) => {
    const span = getSpan(parent)
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