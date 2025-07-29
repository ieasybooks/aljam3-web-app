export function debounce(callback, delay) {
  let timeout

  return (...args) => {
    clearTimeout(timeout)

    timeout = setTimeout(() => {
      callback.apply(this, args)
    }, delay)
  }
}
