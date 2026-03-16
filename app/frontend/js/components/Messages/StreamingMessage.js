import React from "react"
import render from "~/js/components/Messages/render"

export default function StreamingMessage({markdown}) {
  return (
    <div className="mt-3 flex">
      <div
        className="max-w-[85%] rounded-3xl rounded-bl-lg bg-white px-4 py-3 text-zinc-900 shadow-sm ring-1 ring-zinc-200"
        dangerouslySetInnerHTML={{
          __html: `<div class="assistant-content max-w-none whitespace-normal [&_p]:my-0 [&_pre]:overflow-x-auto [&_pre]:rounded-2xl [&_pre]:bg-zinc-100 [&_pre]:p-3 [&_code]:font-mono [&_blockquote]:border-l-4 [&_blockquote]:border-zinc-300 [&_blockquote]:pl-4 [&_blockquote]:text-zinc-600">${render(markdown, {images: false})}</div>`
        }}
      />
    </div>
  )
}
