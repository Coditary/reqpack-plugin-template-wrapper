return {
  name = "template search",
  request = {
    action = "search",
    system = "template",
    prompt = "delta",
  },
  expect = {
    success = true,
    events = { "searched" },
    resultCount = 1,
    resultName = "delta",
    resultVersion = "template",
  }
}
