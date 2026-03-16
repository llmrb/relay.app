import React from "react"

export default function UserMessage({text}) {
  return (
    <div className="mt-3 flex justify-end first:mt-0">
      <div className="max-w-[75%] rounded-3xl rounded-br-lg bg-zinc-900 px-4 py-3 text-white shadow-sm">
        {text}
      </div>
    </div>
  )
}
