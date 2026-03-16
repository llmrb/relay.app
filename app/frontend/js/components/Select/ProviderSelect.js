import React from 'react'

export default function ProviderSelect ({ provider, onChange }) {
  return (
    <label className='flex items-center gap-2'>
      <span>Provider</span>
      <select
        className='rounded-xl border border-zinc-200 bg-white px-3 py-2 text-zinc-900 outline-none focus:border-zinc-300 focus:ring-4 focus:ring-zinc-900/10'
        value={provider}
        onChange={onChange}
      >
        <option value='openai'>OpenAI</option>
        <option value='gemini'>Gemini</option>
        <option value='anthropic'>Anthropic</option>
        <option value='deepseek'>DeepSeek</option>
        <option value='xai'>xAI</option>
      </select>
    </label>
  )
}
