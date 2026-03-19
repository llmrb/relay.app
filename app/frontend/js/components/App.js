/* global HTMLImageElement */

import React, { useEffect, useLayoutEffect, useRef, useState } from 'react'

import {
  AssistantMessage,
  StreamingMessage,
  SystemMessage,
  UserMessage
} from '~/js/components/Messages'

import { ModelSelect, ProviderSelect } from '~/js/components/Select'
import { useModels, useWebSocket } from '~/js/hooks'

export default function App () {
  const [message, setMessage] = useState('')
  const [session, setSession] = useState({ provider: 'deepseek', model: '', cost: '' })
  const { loading: modelsLoading, model, models } = useModels({ session, setSession })
  const { entries, send, status, streaming } = useWebSocket({session, setSession})

  const streamRef = useRef(null)
  const inputRef = useRef(null)
  const keysRef = useRef([])

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

  const onProviderChange = (event) => {
    setSession((prev) => ({...prev, provider: event.target.value, model: '', cost: ''}))
  }

  const onModelChange = (event) => {
    setSession((prev) => ({...prev, model: event.target.value, cost: ''}))
  }

  useLayoutEffect(() => {
    scrollToBottom()
  }, [entries, streaming])

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
      case 'gemini':
        setSession((prev) => ({...prev, model: 'gemini-pro-latest'}))
        break;
    }
  }, [session.provider])

  return (
    <main className='h-screen bg-white font-sans text-zinc-900'>
      <div className='mx-auto flex h-full min-h-0 w-full max-w-none gap-4 px-4 py-6 sm:px-6'>
        <aside className='hidden shrink-0 lg:flex lg:w-56 lg:flex-col lg:items-center lg:gap-4 lg:pt-2'>
          <a target='_blank' rel='noopener noreferrer' href='https://www.youtube.com/watch?v=CyzdOtyYnng'>
            <img
              className='max-h-16 w-auto max-w-[11rem] rounded-2xl [animation:spin_1.5s_linear_1]'
              src='/images/realtalk.png'
              alt='RealTalk'
            />
          </a>
          <div className='flex w-full flex-col gap-3 text-sm text-zinc-500'>
            <ProviderSelect provider={session.provider} onChange={onProviderChange} />
            <ModelSelect
              loading={modelsLoading}
              model={model}
              models={models}
              onChange={onModelChange}
            />
            <span className='text-center text-xs text-zinc-400'>
              {modelsLoading ? '...' : `${models.length} models`}
            </span>
            <div className='rounded-2xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-center'>
              <p className='text-[11px] font-semibold uppercase tracking-[0.2em] text-emerald-700'>
                Session Cost
              </p>
              <p className='mt-1 text-2xl font-semibold text-emerald-950'>
                {session.cost || '$0.00'}
              </p>
            </div>
          </div>
        </aside>
        <div className='flex min-h-0 min-w-0 flex-1 flex-col gap-4'>
        <div
          id='stream'
          ref={streamRef}
          className='min-h-0 flex-1 overflow-y-auto rounded-3xl border border-zinc-200 bg-zinc-50 p-4 text-[15px] leading-7 shadow-sm'
        >
          {entries.map((entry, index) => {
            if (entry.kind === 'assistant') { return <AssistantMessage key={index} markdown={entry.markdown} /> }
            if (entry.kind === 'user') { return <UserMessage key={index} text={entry.text} /> }
            return <SystemMessage key={index} text={entry.text} />
          })}
          {streaming ? <StreamingMessage markdown={streaming} /> : null}
        </div>
        <p className='text-left text-sm text-zinc-500'>
          Status: <span className='font-semibold text-zinc-700'>{status}</span>
        </p>
        <form
          className='sticky bottom-0 flex flex-col gap-2 bg-gradient-to-b from-white/0 via-white/90 to-white pt-3 pb-1'
          onSubmit={onSubmit}
        >
          <textarea
            ref={inputRef}
            rows={1}
            className='max-h-60 min-h-14 w-full resize-none overflow-y-auto rounded-2xl border border-zinc-200 bg-white px-4 py-3 text-[15px] text-zinc-900 outline-none placeholder:text-zinc-400 focus:border-zinc-300 focus:ring-4 focus:ring-zinc-900/10'
            placeholder='Type a message'
            autoComplete='off'
            value={message}
            onChange={(event) => setMessage(event.target.value)}
            onKeyDown={onMessageKeyDown}
            onKeyUp={onMessageKeyUp}
          />
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
