import { FileUpload } from "../file_upload"
import { ActivityController } from "./controllers/ActivityController"
import { ContentController } from "./controllers/ContentController"
import { Scroll } from "../scroll"
import { Timer } from "../timer"

export const Relay = () => {
  const target = document
  const timer = Timer(document.getElementById("chatbot-status"))
  const activity = ActivityController({target})
  const content = ContentController({target})
  const controllers = [activity, content]
  let scroll = Scroll(document.getElementById("chatbot-stream"))

  const refreshScroll = () => {
    const stream = document.getElementById("chatbot-stream")
    if (!stream)
      return
    if (!scroll || scroll.parentEl !== stream)
      scroll = Scroll(stream)
  }

  const enhance = (root = document.body) => {
    refreshScroll()
    controllers.forEach((controller) => controller.enhance(root))
  }

  const syncTimer = () => {
    const status = document.getElementById("chatbot-status")
    if (!timer || !status)
      return
    timer.parentEl = status
    timer.handle(status)
  }

  const fileUpload = FileUpload({afterUpload: enhance})

  const handleOobSwap = (event) => {
    const elt = event.detail.elt || event.target
    enhance(elt)
    syncTimer()
    scroll?.followIfNeeded()
  }

  const handleAfterSwap = (event) => {
    const elt = event.detail.elt || event.target
    enhance(elt)
    syncTimer()
    scroll?.followIfNeeded()
  }

  const handleSubmit = (event) => {
    if (event.target.id !== "chat-composer")
      return
    if (fileUpload.blockSubmit(event))
      return
    scroll?.force()
  }

  const handleFocus = (event) => {
    if (!event.target.matches("#chat-composer textarea"))
      return
    scroll?.force()
  }

  const handleInput = (event) => {
    if (!event.target.matches("#chat-composer textarea"))
      return
    scroll?.force()
  }

  const handleChange = (event) => {
    if (!event.target.matches("#file-upload-input"))
      return
    fileUpload.upload(event.target.files?.[0])
  }

  const bindEvents = () => {
    document.body.addEventListener("htmx:oobAfterSwap", handleOobSwap)
    document.body.addEventListener("htmx:afterSwap", handleAfterSwap)
    document.body.addEventListener("submit", handleSubmit)
    document.body.addEventListener("focusin", handleFocus)
    document.body.addEventListener("input", handleInput)
    document.body.addEventListener("change", handleChange)
    window.addEventListener("load", () => scroll?.force(), { once: true })
  }

  return {
    start() {
      controllers.forEach((controller) => controller.start())
      bindEvents()
      enhance()
      syncTimer()
      requestAnimationFrame(() => scroll?.force())
    },
    stop() {
      controllers.forEach((controller) => controller.stop())
    }
  }
}
