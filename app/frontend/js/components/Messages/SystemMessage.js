import React from 'react'

export default function SystemMessage ({ text }) {
  const className = [
    'mt-3 text-center text-xs text-zinc-500 first:mt-0'
  ].join(' ')

  return <div className={className}>{text}</div>
}
