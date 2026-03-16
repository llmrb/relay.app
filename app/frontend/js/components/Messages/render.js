import { marked } from 'marked'

const origin = window.location.origin

const stripImages = (markdown) => {
  return markdown
    .replace(/!\[([^\]]*)\]\([^)]+\)/g, (_match, alt) => {
      return `\n\n> [image${alt ? `: ${alt}` : ''} loading]\n\n`
    })
    .replace(/<img\b[^>]*alt=(['"])(.*?)\1[^>]*>/gi, (_match, _quote, alt) => {
      return `\n\n> [image${alt ? `: ${alt}` : ''} loading]\n\n`
    })
    .replace(/<img\b[^>]*>/gi, '\n\n> [image loading]\n\n')
}

export default function render (markdown, { images = true } = {}) {
  const content = images ? markdown : stripImages(markdown)
  return marked.parse(content.replaceAll('sandbox:/', `${origin}/`))
}
