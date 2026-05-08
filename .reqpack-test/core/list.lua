return {
  name = "template list",
  request = {
    action = "list",
    system = "template",
  },
  expect = {
    success = true,
    events = { "listed" },
    resultCount = 0,
  }
}
