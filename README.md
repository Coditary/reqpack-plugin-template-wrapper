# reqpack-plugin-template-wrapper

GitHub template for new ReqPack wrapper plugins.

It ships a tiny no-op skeleton that shows where metadata, bootstrap logic, command execution, and plugin tests belong.

## Included Files

- `template.lua`: full wrapper skeleton with all common entry points
- `bootstrap.lua`: optional bootstrap stub
- `API.md`: small API quick reference based on `ReqPack.wiki`
- `.reqpack-test/core/info.lua`: minimal `info` conformance example
- `.reqpack-test/core/list.lua`: minimal `list` conformance example
- `.reqpack-test/core/search.lua`: minimal `search` conformance example

## How To Use

1. Create a new repository from this template.
2. Rename `template.lua` to your plugin id, for example `brew.lua` or `apt.lua`.
3. Replace placeholder metadata in `getName()`, `getVersion()`, and `getCategories()`.
4. Add real package-manager logic to `install`, `remove`, `update`, `list`, `search`, and `info`.
5. Adjust `.reqpack-test/core/*.lua` so they match your plugin behavior.

## File Guide

Before filling in real behavior, read `API.md`.
It is short and points back to full docs in `ReqPack.wiki/Extending-Writing-Lua-Plugins.md`.

### `template.lua`

Main wrapper file.

Important sections:

- helper functions at top for small reusable utilities
- metadata methods for plugin name, version, requirements, categories
- command methods for install/remove/update/list/search/info
- lifecycle methods `init()` and `shutdown()`

The shipped implementation is intentionally empty.
It returns safe defaults and emits a few example events so test cases show expected result shapes.

### `bootstrap.lua`

Optional setup hook.

Put things here like:

- dependency checks
- first-run marker files
- helper binary downloads
- local cache preparation

The shipped version only returns `true`.

### `.reqpack-test/core/*.lua`

Minimal hermetic plugin tests.

They show how ReqPack test cases are structured:

- `request`
- `fakeExec`
- `expect`

## Running Plugin Tests

After renaming `template.lua` to your plugin id, run:

```bash
rqp test-plugin --plugin ./your-plugin.lua --preset core
```

Or point at plugin directory from its parent directory after you renamed file to match directory name:

```bash
rqp test-plugin --plugin ./your-plugin-dir --preset core
```

You can also run one case directly:

```bash
rqp test-plugin --plugin ./your-plugin.lua --case ./.reqpack-test/core/info.lua
```

## Notes

- Keep comments short.
- Prefer small helper functions over repeated shell string building.
- Emit `context.events.*` when returning package information so ReqPack can record useful results.
- Once plugin does real work, update tests before expanding behavior.
