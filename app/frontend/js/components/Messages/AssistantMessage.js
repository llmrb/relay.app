import React from "react"
import render from "~/js/components/Messages/render"

export default React.memo(function AssistantMessage({markdown}) {
  return (
    <div className="mt-3 flex first:mt-0">
      <div
        className="max-w-[85%] rounded-3xl rounded-bl-lg bg-white px-4 py-3 text-zinc-900 shadow-sm ring-1 ring-zinc-200"
        dangerouslySetInnerHTML={{
          __html: `<div class="assistant-content max-w-none whitespace-normal [&_p]:my-0 [&_pre]:overflow-x-auto [&_pre]:rounded-2xl [&_pre]:bg-zinc-100 [&_pre]:p-3 [&_code]:font-mono [&_blockquote]:border-l-4 [&_blockquote]:border-zinc-300 [&_blockquote]:pl-4 [&_blockquote]:text-zinc-600 [&_img]:mt-2 [&_img]:h-auto [&_img]:max-h-[32rem] [&_img]:w-full [&_img]:max-w-2xl [&_img]:rounded-2xl [&_img]:object-contain">${render(markdown)}</div>`
        }}
      />
    </div>
  )
})
