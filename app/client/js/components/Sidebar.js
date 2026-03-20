import React from "react"
import { ModelSelect, ProviderSelect } from '~/js/components/Select'

export function Sidebar({session, models, modelsLoading, onProviderChange, onModelChange}) {
  return (
    <aside className='hidden shrink-0 lg:flex lg:h-full lg:w-56 lg:flex-col lg:pt-2'>
      <div className='flex flex-col items-center gap-4'>
        <a target='_blank' rel='noopener noreferrer' href='https://www.youtube.com/watch?v=CyzdOtyYnng'>
          <img
            className='max-h-16 w-auto max-w-[11rem] rounded-2xl [animation:spin_1.5s_linear_1]'
            src='/images/relay.png'
            alt='Relay'
          />
        </a>
        <div className='flex w-full flex-col gap-3 text-sm text-zinc-500'>
          <ProviderSelect provider={session.provider} onChange={onProviderChange} />
          <ModelSelect
            loading={modelsLoading}
            model={session.model}
            models={models}
            onChange={onModelChange}
          />
          <span className='text-center text-xs text-zinc-400'>
            {modelsLoading ? '...' : `${models.length} models`}
          </span>
        </div>
      </div>
    </aside>
  )
}
