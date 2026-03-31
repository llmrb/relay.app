import "../css/application.css"
import htmx from "htmx.org"
import hljs from "highlight.js"

window.htmx = htmx
require("htmx-ext-ws")

import { Jukebox } from "../js/jukebox"
import { Scroll } from "../js/scroll"
import { Timer } from "../js/jukebox/timer"

;(function() {
  document.addEventListener("DOMContentLoaded", () => {
    const jukebox = Jukebox()
    const timer = Timer(document.getElementById("chatbot-status"))
    const scroll = Scroll(document.getElementById("chatbot-stream"))
    const composer = document.getElementById("chat-composer")

    const syntaxHighlight = (el) =>{
      hljs.highlightElement(el)
    }

    const modifyAnchors = (el) =>{
      el.setAttribute("target", "_blank")
      el.setAttribute("rel", "noreferrer noopener")
    }

    const enhance = (root = document.body) => {
      root.querySelectorAll("pre code").forEach(syntaxHighlight)
      root.querySelectorAll("a").forEach(modifyAnchors)
      const nodes = root.querySelectorAll(".assistant-content")
      if (nodes.length > 0)
        jukebox.scanForMusic(nodes[nodes.length - 1])
    }

    document.body.addEventListener("htmx:oobAfterSwap", (event) => {
      const elt = event.detail.elt || event.target
      if (elt.id === "chatbot-status") {
        timer.parentEl = elt
        timer.handle(elt)
        return
      }
      enhance(elt)
      scroll?.follow()
    })

    document.body.addEventListener("htmx:afterSwap", (event) => {
      const elt = event.detail.elt || event.target
      enhance(elt)
    })

    composer?.addEventListener("submit", () => {
      scroll?.force()
    })

    enhance()
    requestAnimationFrame(() => scroll?.force())
    window.addEventListener("load", () => scroll?.force(), { once: true })
  })
})()
