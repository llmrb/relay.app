import React from 'react'

export default function UserMessage ({ text }) {
  const containerClassName = [
    'mt-3 flex justify-end first:mt-0'
  ].join(' ')
  const bubbleClassName = [
    'max-w-[75%] rounded-3xl rounded-br-lg bg-zinc-900 px-4 py-3',
    'text-white shadow-sm'
  ].join(' ')

  return (
    <div className={containerClassName}>
      <div className={bubbleClassName}>
        {text}
      </div>
    </div>
  )
}
