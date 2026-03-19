import React from 'react'
import render from '~/js/components/Messages/render'

export default React.memo(function AssistantMessage ({ markdown }) {
  const containerClassName = [
    'mt-3 flex first:mt-0'
  ].join(' ')
  const bubbleClassName = [
    'max-w-[85%] rounded-3xl rounded-bl-lg bg-white px-4 py-3',
    'text-zinc-900 shadow-sm ring-1 ring-zinc-200'
  ].join(' ')
  const contentClassName = [
    'assistant-content max-w-none whitespace-normal leading-7',
    '[&_p]:my-4 [&_p:first-child]:mt-0 [&_p:last-child]:mb-0',
    '[&_ul]:my-4 [&_ul]:list-disc [&_ul]:pl-6',
    '[&_ol]:my-4 [&_ol]:list-decimal [&_ol]:pl-6',
    '[&_li]:my-1.5',
    '[&_pre]:my-4 [&_pre]:overflow-x-auto [&_pre]:rounded-2xl',
    '[&_pre]:bg-zinc-100 [&_pre]:p-3 [&_code]:font-mono',
    '[&_blockquote]:my-4 [&_blockquote]:border-l-4',
    '[&_blockquote]:border-zinc-300 [&_blockquote]:pl-4',
    '[&_blockquote]:text-zinc-600',
    '[&_img]:mt-2 [&_img]:h-auto [&_img]:max-h-[32rem]',
    '[&_img]:w-full [&_img]:max-w-2xl [&_img]:rounded-2xl',
    '[&_img]:object-contain'
  ].join(' ')

  return (
    <div className={containerClassName}>
      <div
        className={bubbleClassName}
        dangerouslySetInnerHTML={{
          __html: `<div class="${contentClassName}">${render(markdown)}</div>`
        }}
      />
    </div>
  )
})
