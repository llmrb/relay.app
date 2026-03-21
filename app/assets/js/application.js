import "../css/application.css"
import htmx from "htmx.org"
import { marked } from "marked"

window.htmx = htmx
window.marked = marked

require("htmx-ext-ws")

// Server-rendered app entrypoint for future client-side behavior.
