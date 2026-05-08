return {
  name = "template info",
  request = {
    action = "info",
    system = "template",
    prompt = "delta",
  },
  expect = {
    success = true,
    events = { "informed" },
    resultCount = 1,
    resultName = "delta",
    resultVersion = "template",
  }
}
