import { useEffect, useState } from 'react'

export default function useModels (provider) {
  const [models, setModels] = useState([])
  const [model, setModel] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(false)

  useEffect(() => {
    const controller = new AbortController()
    setModels([])
    setModel('')
    setLoading(true)
    setError(false)
    fetch(`/models?provider=${encodeURIComponent(provider)}`, { signal: controller.signal })
      .then((response) => response.json())
      .then((payload) => {
        setModels(payload)
        setModel(payload[0]?.id || '')
        setLoading(false)
      })
      .catch((error) => {
        if (error.name === 'AbortError') {
          return
        }
        setLoading(false)
        setError(true)
      })

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
