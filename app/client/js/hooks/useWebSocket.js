/* global WebSocket */

import { useEffect, useState } from 'react'

const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'

export default function useWebSocket ({session, setSession}) {
  const [status, setStatus] = useState('connecting')
  const [entries, setEntries] = useState([])
  const [reconnectKey, setReconnectKey] = useState(0)
  const [stream, setStream] = useState('')
  const [socket, setSocket] = useState(null)

  const say = (kind, text) => {
    setEntries((prev) => [...prev, { kind, text }])
  }

  const reconnect = () => {
    setReconnectKey((prev) => prev + 1)
  }

  const error = () => {
    setStream('')
    setStatus('Try again')
    say('system', 'server: server error')
  }

  const send = (message) => {
    if (!socket || socket.readyState !== WebSocket.OPEN) {
      say('client: socket is not open')
      return false
    }
    setStatus('waiting')
    say('user', message)
    socket.send(message)
    return true
  }

  const onMessage = (payload) => {
    switch (payload.event) {
      case 'welcome':
        const { provider, model, contextWindow } = payload
        setSession((prev) => ({...prev, contextWindow}))
        say('system', `server: connected (${provider} / ${model})`)
        break
      case 'status':
        setStatus(payload.message)
        break
      case 'delta':
        setStream((prev) => prev + payload.message)
        break
      case 'done':
        setStream((current) => {
          if (current) { setEntries((prev) => [...prev, { kind: 'assistant', markdown: current }]) }
          return ''
        })
        const { contextWindowUsage } = payload
        if (payload.cost === 'unknown') {
          setSession((prev) => ({...prev, cost: payload.cost, contextWindowUsage}))
        } else {
          setSession((prev) => ({...prev, cost: `$${payload.cost}`, contextWindowUsage}))
        }
        setStatus('ready')
        break
      case 'error':
        error('server: server error')
        break
      default:
        break
    }
  }

  useEffect(() => {
    if (!session.model) { return }

    let active = true
    const query = `provider=${encodeURIComponent(session.provider)}&model=${encodeURIComponent(session.model)}`
    const socket = new WebSocket(`${protocol}//${window.location.host}/ws?${query}`)
    setSocket(socket)
    setStatus('connecting')

    socket.addEventListener('open', () => {
      if (!active) { return }
      setStatus('ready')
    })

    socket.addEventListener('close', () => {
      if (!active) { return }
      say("client: connection closed")
      reconnect()
    })

    socket.addEventListener('error', () => {
      if (!active) { return }
      say('client: socket error')
      reconnect()
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
  }, [session.provider, session.model, reconnectKey])

  return {
    entries,
    send,
    status,
    stream
  }
}
