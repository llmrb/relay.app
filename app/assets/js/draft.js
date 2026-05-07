const Draft = () => {
  const prefix = "relay:draft"

  const composer = () => {
    return document.getElementById("chat-composer")
  }

  const textarea = () => {
    return composer()?.querySelector("textarea[name='message']")
  }

  const key = (form = composer()) => {
    if (!form?.dataset.contextId)
      return null
    return [prefix, form.dataset.contextId].join(":")
  }

  const restore = () => {
    const el = textarea()
    const currentKey = key()
    if (!el || !currentKey)
      return
    const value = localStorage.getItem(currentKey)
    if (value === null)
      return
    el.value = value
  }

  const persist = (el) => {
    const currentKey = key(el?.form)
    if (!currentKey)
      return
    if (el.value.length === 0)
      localStorage.removeItem(currentKey)
    else
      localStorage.setItem(currentKey, el.value)
  }

  const clear = (form = composer()) => {
    const currentKey = key(form)
    if (!currentKey)
      return
    localStorage.removeItem(currentKey)
  }

  return {clear, persist, restore}
}

export { Draft }
