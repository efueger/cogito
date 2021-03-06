async function delay (milliseconds) {
  return new Promise(function (resolve) {
    setTimeout(() => resolve(), milliseconds)
  })
}

export { delay }
