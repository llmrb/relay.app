import React from "react"
import { ModelSelect, ProviderSelect } from '~/js/components/Select'

export function Sidebar({session, models, modelsLoading, onProviderChange, onModelChange}) {
  return (
    <aside className='hidden shrink-0 lg:flex lg:w-56 lg:flex-col lg:items-center lg:gap-4 lg:pt-2'>
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
        <Cost cost={session.cost} />
      </div>
    </aside>
  )
}

function Cost({cost}) {
  return (
    <div className='rounded-2xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-center'>
      <p className='text-[11px] font-semibold uppercase tracking-[0.2em] text-emerald-700'>
        Session Cost
      </p>
      <p className='mt-1 text-2xl font-semibold text-emerald-950'>
        {cost || '$0.00'}
      </p>
    </div>
  )
}
