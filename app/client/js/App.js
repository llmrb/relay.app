/* global HTMLImageElement */

import React, { useEffect, useLayoutEffect, useRef, useState } from 'react'

import {
  TextArea,
} from "~/js/components/TextArea"

import {
  Sidebar
} from "~/js/components/Sidebar"

import {
  AssistantMessage,
  StreamingMessage,
  SystemMessage,
  UserMessage
} from '~/js/components/Messages'

import { useModels, useWebSocket } from '~/js/hooks'

export default function App () {
  const defaults = {
    provider: 'deepseek', model: '', cost: '',
    contextWindow: '', contextWindowUsage: ''
  }
  const resetState = { cost: '', contextWindow: '', contextWindowUsage: '' }

  const [message, setMessage] = useState('')
  const [session, setSession] = useState(defaults)
  const { loading: modelsLoading, models } = useModels({ session, setSession })
  const { entries, send, status, stream } = useWebSocket({session, setSession})

  const streamRef = useRef(null)
  const inputRef = useRef(null)

  const onProviderChange = (event) => {
    setSession((prev) => ({...prev, ...resetState, provider: event.target.value, model: ''}))
  }

  const onModelChange = (event) => {
    setSession((prev) => ({...prev,...resetState,model: event.target.value}))
  }

  const scrollToBottom = () => {
    const stream = streamRef.current
    if (stream) stream.scrollTop = stream.scrollHeight
  }

  const onSubmit = (event) => {
    event.preventDefault()
    const text = message.trim()
    if (!text) return false
    if (send(text)) setMessage('')
  }

  useLayoutEffect(() => {
    scrollToBottom()
  }, [entries, stream])

  useEffect(() => {
    const stream = streamRef.current
    if (!stream) return
    const onLoad = (event) => {
      if (event.target instanceof HTMLImageElement) scrollToBottom()
    }
    stream.addEventListener('load', onLoad, true)
    return () => stream.removeEventListener('load', onLoad, true)
  }, [])

  useEffect(() => {
    inputRef.current?.focus()
  }, [])

  useEffect(() => {
    const input = inputRef.current
    if (!input) return
    input.style.height = '0px'
    input.style.height = `${Math.min(input.scrollHeight, 240)}px`
  }, [message])

  useEffect(() => {
    switch(session.provider) {
      case 'openai':
        setSession((prev) => ({...prev, model: 'gpt-5.4'}))
        break;
      case 'google':
        setSession((prev) => ({...prev, model: 'google-pro-latest'}))
        break;
    }
  }, [session.provider])

  return (
    <main className='h-screen bg-white font-sans text-zinc-900'>
      <div className='mx-auto flex h-full min-h-0 w-full max-w-none gap-4 px-4 py-6 sm:px-6'>
        <Sidebar
          session={session}
          models={models}
          modelsLoading={modelsLoading}
          onProviderChange={onProviderChange}
          onModelChange={onModelChange}
        />
        <div className='flex min-h-0 min-w-0 flex-1 flex-col gap-4'>
        <div
          id='stream'
          ref={streamRef}
          className='min-h-0 flex-1 overflow-y-auto rounded-3xl border border-zinc-200 bg-zinc-50 p-4 text-[15px] leading-7 shadow-sm'
        >
          {entries.map((entry, index) => {
            if (entry.kind === 'assistant') { return <AssistantMessage key={index} markdown={entry.markdown} /> }
            if (entry.kind === 'user') { return <UserMessage key={index} text={entry.text} /> }
            if (entry.kind === 'system') { return <SystemMessage key={index} text={entry.text} /> }
          })}
          {stream ? <StreamingMessage markdown={stream} /> : null}
        </div>
        <div className='grid grid-cols-[1fr_auto_1fr] items-center gap-4 text-sm text-zinc-500'>
          <p className='min-w-0'>
            <span className='font-semibold text-zinc-700'>{status}</span>
          </p>
          <p className='text-center'>
            <span className='font-semibold text-zinc-800'>{session.cost || '$0.00'}</span>
          </p>
          <div />
        </div>
        <form
          className='sticky bottom-0 flex flex-col gap-2 bg-gradient-to-b from-white/0 via-white/90 to-white pt-3 pb-1'
          onSubmit={onSubmit}
        >
          <TextArea inputRef={inputRef} message={message} setMessage={setMessage} onSubmit={onSubmit} />
          <div className='flex justify-end'>
            <button
              disabled={status !== 'ready'}
              className='min-w-24 rounded-full bg-zinc-900 px-4 py-3 text-sm font-semibold text-white transition hover:bg-zinc-800 focus:ring-4 focus:ring-zinc-900/10 focus:outline-none'
              type='submit'
            >
              Send
            </button>
          </div>
        </form>
        </div>
      </div>
    </main>
  )
}
