import React, { useRef } from "react"

export function TextArea({inputRef, message, setMessage, onSubmit}) {
  const keysRef = useRef([])
  const className = [
    'max-h-60 min-h-14 w-full resize-none overflow-y-auto',
    'rounded-2xl border border-zinc-200 bg-white px-4 py-3 text-[15px]',
    'text-zinc-900 outline-none placeholder:text-zinc-400',
    'focus:border-zinc-300 focus:ring-4 focus:ring-zinc-900/10'
  ].join(' ')

  const onMessageKeyDown = (event) => {
    const keys = keysRef.current
    if (event.nativeEvent.isComposing) return
    if (!keys.includes(event.key)) keys.push(event.key)

    const enters = keys.filter((key) => key === 'Enter')
    const shifts = keys.filter((key) => key === 'Shift')

    if (enters.length && !shifts.length) {
      onSubmit(event)
      keysRef.current = []
    }
  }

  const onMessageKeyUp = (event) => {
    const keys = keysRef.current
    keysRef.current = keys.filter((key) => key !== event.key)
  }

  return (
      <textarea
        ref={inputRef}
        rows={1}
        className={className}
        placeholder='Type a message'
        autoComplete='off'
        value={message}
        onChange={(event) => setMessage(event.target.value)}
        onKeyDown={onMessageKeyDown}
        onKeyUp={onMessageKeyUp}
      />
  )
}
