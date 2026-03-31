export const Scroll = (parentEl) => {
  if (!parentEl)
    return null

  const self = Object.create(null)
  const threshold = 8
  const onScroll = () => {
    if (ignoreScroll) return
    following = isNearBottom()
    if (!following)
      self.cancel()
  }
  const isNearBottom = () => {
    return (parentEl.scrollHeight - (parentEl.scrollTop + parentEl.clientHeight)) <= threshold
  }

  let following = true
  let followFrame = null
  let ignoreScroll = false

  self.parentEl = parentEl

  self.cancel = () => {
    if (!followFrame) return
    cancelAnimationFrame(followFrame)
    followFrame = null
  }

  self.scroll = () => {
    ignoreScroll = true
    parentEl.scrollTop = parentEl.scrollHeight
    requestAnimationFrame(() => {
      parentEl.scrollTop = parentEl.scrollHeight
      ignoreScroll = false
      following = isNearBottom()
    })
  }

  self.follow = () => {
    if (!following || followFrame) return
    followFrame = requestAnimationFrame(() => {
      followFrame = null
      self.scroll()
    })
  }

  self.force = () => {
    following = true
    self.scroll()
  }

  following = isNearBottom()
  parentEl.addEventListener("scroll", onScroll, { passive: true })

  return self
}
