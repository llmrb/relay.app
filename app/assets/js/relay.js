import "../css/application.css"
import htmx from "htmx.org"
import hljs from "highlight.js"
import { marked } from "marked"

window.htmx = htmx
window.marked = marked
require("htmx-ext-ws")

;(function() {
  document.addEventListener("DOMContentLoaded", () => {
    const scroll = () => {
      const stream = document.getElementById("chatbot-stream")
      if (!stream) return
      stream.scrollTop = stream.scrollHeight
    }

    const follow = () => {
      scroll()
      requestAnimationFrame(scroll)
      setTimeout(scroll, 0)
      setTimeout(scroll, 32)
    }

    const syntaxHighlight = (el) =>{
      hljs.highlightElement(el)
    }

    const modifyAnchors = (el) =>{
      el.setAttribute("target", "_blank")
      el.setAttribute("rel", "noreferrer noopener")
    }

    const updateMediaDock = (parentEl) => {
      const media = parentEl.querySelector("[data-media-dock]")
      const dock = document.getElementById("media-dock")
      const title = document.getElementById("media-dock-title")
      const body = document.getElementById("media-dock-body")
      if (!media || !dock || !title || !body) return

      dock.classList.remove("hidden")
      title.textContent = media.dataset.mediaTitle || "Now Playing"
      const nextFrame = media.querySelector("iframe")
      const currentFrame = body.querySelector("iframe")
      const nextSrc = nextFrame?.getAttribute("src") || ""
      const currentSrc = currentFrame?.getAttribute("src") || ""

      if (nextSrc && nextSrc !== currentSrc) {
        body.replaceChildren(media)
      }

      const notice = document.createElement("p")
      notice.className = "my-3 rounded-2xl border border-blue-200 bg-blue-50 px-4 py-3 text-sm font-medium text-blue-700"
      notice.textContent = `${title.textContent} is playing in the media dock.`
      parentEl.replaceChildren(notice)
    }

    const markdown = (root = document.body) => {
      root.querySelectorAll("[data-markdown]").forEach((parentEl) => {
        parentEl.innerHTML = marked.parse(parentEl.dataset.markdownSource || "")
        parentEl.querySelectorAll("pre code").forEach(syntaxHighlight)
        parentEl.querySelectorAll("a").forEach(modifyAnchors)
        updateMediaDock(parentEl)
      })
    }

    markdown()
    follow()

    document.body.addEventListener("htmx:afterSwap", (event) => markdown(event.target))
    document.body.addEventListener("htmx:oobAfterSwap", (event) => {
      markdown(event.target)
      follow()
    })
  })
})()
