import { useEffect, useState } from 'react'

export default function useModels (provider) {
  const [models, setModels] = useState([])
  const [model, setModel] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(false)

  const unmarshal = (response) => response.json()

  const clear = (response) => {
    setModels([])
    setModel('')
    setLoading(true)
    setError(false)
    return response
  }

  const receive = (payload) => {
    setModels(payload)
    setModel(payload[0]?.id || '')
    setLoading(false)
    return payload
  }

  const onError = (error) => {
    if (error.name === 'AbortError') {
      return
    }
    setLoading(false)
    setError(true)
  }

  useEffect(() => {
    const controller = new AbortController()
    fetch(`/models?provider=${encodeURIComponent(provider)}`, { signal: controller.signal })
      .then(clear)
      .then(unmarshal)
      .then(receive)
      .catch(onError)
    return () => controller.abort()
  }, [provider])

  return {
    error,
    loading,
    model,
    models,
    setModel
  }
}
