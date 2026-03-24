import { Player } from "./jukebox/player"

export const Jukebox = () => {
  const self = { activePlayer: null }

  const nowPlaying = (title) => {
    const notice = document.createElement("p")
    notice.className = "my-3 rounded-2xl border border-blue-200 bg-blue-50 px-4 py-3 text-sm font-medium text-blue-700"
    notice.textContent = `${title} is playing on the jukebox!`
    return notice
  }

  const getArtist = (node) =>{
    const artistEl = node.querySelector(".artist")
    if (artistEl) {
      const attrs = Array.from(artistEl.querySelectorAll("[data-name]"))
      const entries = attrs.map((el) => [el.dataset.name, el.textContent.trim()])
      const artist = Object.fromEntries(entries)
      artist.el = artistEl
      return artist
    } else {
      return null
    }
  }

  const replace = (newPlayer, oldPlayer) => {
    self.activePlayer = newPlayer
    newPlayer.show()
    oldPlayer.replaceWith(newPlayer)
  }

  self.scanForMusic = (node) => {
    const newPlayer = Player(Player.template())
    const activePlayer = Player(document.querySelector("#jukebox"))
    const artist = getArtist(node)
    if (!newPlayer || !activePlayer || !artist)
      return
    newPlayer.setArtist(artist)
    artist.el.replaceWith(nowPlaying(newPlayer.getTitle()))
    if (newPlayer.getSrc() === activePlayer.getSrc())
      return
    replace(newPlayer, activePlayer)
  }

  return self
}
