import "../css/application.css"
import htmx from "htmx.org"
import hljs from "highlight.js"
import { marked } from "marked"

window.htmx = htmx
window.marked = marked
require("htmx-ext-ws")

import { Jukebox } from "../js/jukebox"

;(function() {
  document.addEventListener("DOMContentLoaded", () => {
    const jukebox = Jukebox()
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

    const markdown = (root = document.body) => {
      const nodes = root.querySelectorAll("[data-markdown]")
      nodes.forEach((node, index) => {
        node.innerHTML = marked.parse(node.dataset.markdownSource || "")
        node.querySelectorAll("pre code").forEach(syntaxHighlight)
        node.querySelectorAll("a").forEach(modifyAnchors)
        if (index === nodes.length - 1)
          jukebox.scanForMusic(node)
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
