import React from 'react'

export default function ModelSelect ({ loading, model, models, onChange }) {
  return (
    <label className='flex items-center gap-2'>
      <span>Model</span>
      <select
        className='min-w-72 rounded-xl border border-zinc-200 bg-white px-3 py-2 text-zinc-900 outline-none focus:border-zinc-300 focus:ring-4 focus:ring-zinc-900/10 disabled:bg-zinc-100 disabled:text-zinc-400'
        value={model}
        disabled={loading || models.length === 0}
        onChange={onChange}
      >
        {loading
          ? (
            <option value=''>Loading models...</option>
            )
          : (
              models.map((entry) => (
                <option key={entry.id} value={entry.id}>
                  {entry.name || entry.id}
                </option>
              ))
            )}
      </select>
    </label>
  )
}
