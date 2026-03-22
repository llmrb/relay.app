export const Dock = () => {
  const self = { activeMediaId: null }

  const notice = (title) => {
    const notice = document.createElement("p")
    notice.className = "my-3 rounded-2xl border border-blue-200 bg-blue-50 px-4 py-3 text-sm font-medium text-blue-700"
    notice.textContent = `${title} is playing in the media dock.`
    return notice
  }

  const play = (media, body, mediaId) => {
    self.activeMediaId = mediaId
    media.classList.remove("hidden")
    body.replaceChildren(media)
  }

  self.scan = (node) => {
    const video = node.querySelector("[data-media-dock]")
    const dock = document.querySelector("#media-dock")
    const title = dock?.querySelector("#media-dock-title")
    const body = dock?.querySelector("#media-dock-body")

    if (!video || !dock || !title || !body) return

    const iframe = video?.querySelector("iframe")
    const mediaId = iframe?.dataset.mediaId || ""
    if (!video || !iframe || !mediaId) return

    const nextSrc = iframe.getAttribute("src") || ""
    const currentFrame = body.querySelector("iframe")
    const currentSrc = currentFrame?.getAttribute("src") || ""

    dock.classList.remove("hidden")
    title.textContent = video.dataset.mediaTitle || "Now Playing"
    video.replaceWith(notice(title.textContent))

    if (self.activeMediaId === mediaId) return
    if (!nextSrc || nextSrc === currentSrc) return

    play(video, body, mediaId)
  }

  return self
}
