const Player = function (parentEl) {
  if (!parentEl)
    return null

  const self = Object.create(null)
  const titleEl = parentEl.querySelector(".jukebox-title")
  const bodyEl = parentEl.querySelector(".jukebox-body")
  const iframeEl = bodyEl?.querySelector("iframe")

  self.parentEl = parentEl

  self.show = () => {
    parentEl.classList.remove("hidden")
  }

  self.getSrc = () => {
    return iframeEl?.getAttribute("src")
  }

  self.getTitle = () => {
    return titleEl.textContent
  }

  self.setTitle = (title) => {
    titleEl.textContent = title
  }

  self.setTrack = (artist) => {
     iframeEl.src = artist.track
     iframeEl.dataset.id = artist.track
  }

  self.setArtist = (artist) => {
    self.setTitle(`${artist.name} - ${artist.title}`)
    self.setTrack(artist)
  }

  self.replaceWith = (otherPlayer) => {
    bodyEl.replaceChildren(otherPlayer.parentEl)
  }

  return self
}

Player.template = function() {
  const raw = document.getElementById("tmpl-jukebox-player").content
  const tmpl = raw.firstElementChild.cloneNode(true)
  return tmpl
}

export {Player}
