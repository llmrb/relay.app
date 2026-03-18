/* global WebSocket */

import { useEffect, useState } from 'react'

const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'

export default function useWebSocket (provider, model, setModel, setCost) {
  const [status, setStatus] = useState('connecting')
  const [entries, setEntries] = useState([])
  const [streaming, setStreaming] = useState('')
  const [socket, setSocket] = useState(null)

  const _setModel = (payload) => {
    if (payload.model && payload.model !== model) { setModel(payload.model) }
  }

  const say = (text) => {
    setEntries((prev) => [...prev, { kind: 'system', text }])
  }

  const tell = (text) => {
    setEntries((prev) => [...prev, { kind: 'user', text }])
  }

  const stream = (chunk) => {
    setStreaming((prev) => prev + chunk)
  }

  const finish = () => {
    setStreaming((current) => {
      if (current) { setEntries((prev) => [...prev, { kind: 'assistant', markdown: current }]) }
      return ''
    })
  }

  const onMessage = (payload) => {
    switch (payload.event) {
      case 'welcome':
        _setModel(payload)
        say(`server: connected (${payload.provider || provider}${payload.model ? ` / ${payload.model}` : ''})`)
        break
      case 'status':
        setStatus(payload.message)
        break
      case 'delta':
        stream(payload.message)
        break
      case 'done':
        finish()
        payload.cost === 'unknown' ? setCost(payload.cost) : setCost(`$${payload.cost}`)
        setStatus('ready')
        break
      case 'error':
        setStreaming('')
        setStatus('error')
        say('server: server error')
        break
      default:
        break
    }
  }

  useEffect(() => {
    if (!model) { return }

    let active = true
    const query = `provider=${encodeURIComponent(provider)}&model=${encodeURIComponent(model)}`
    const socket = new WebSocket(`${protocol}//${window.location.host}/ws?${query}`)
    setSocket(socket)
    setStatus('connecting')

    socket.addEventListener('open', () => active && setStatus('ready'))
    socket.addEventListener('close', () => active && setStatus('closed'))

    socket.addEventListener('error', () => {
      if (!active) { return }
      setStatus('error')
      say('client: socket error')
    })

    socket.addEventListener('message', (event) => {
      if (!active) { return }
      try {
        const payload = JSON.parse(event.data)
        onMessage(payload)
      } catch (err) {
        say('client: recv failed')
        console.error(err)
      }
    })

    return () => {
      active = false
      socket.close()
    }
  }, [provider, model])

  const send = (message) => {
    if (!socket || socket.readyState !== WebSocket.OPEN) {
      say('client: socket is not open')
      return false
    }
    setStatus('waiting')
    tell(message)
    socket.send(message)
    return true
  }

  return {
    entries,
    send,
    status,
    streaming
  }
}
