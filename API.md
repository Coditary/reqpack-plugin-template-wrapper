# ReqPack Lua Plugin API Quick Reference

Short reference for wrapper authors.
Source of truth is ReqPack wiki page `Extending-Writing-Lua-Plugins` from this project.

## Plugin Layout

Expected layout:

```text
<plugin-id>/
  <plugin-id>.lua
  bootstrap.lua        # optional
  .reqpack-test/
    core/
```

Important:

- main script must expose global `plugin` table
- optional bootstrap hook is global `bootstrap()` function
- script file name should match plugin id when used by plugin directory

## Required Methods

ReqPack expects these methods on `plugin`:

```lua
function plugin.getName() end
function plugin.getVersion() end
function plugin.getRequirements() end
function plugin.getCategories() end
function plugin.getMissingPackages(packages) end
function plugin.install(context, packages) end
function plugin.installLocal(context, path) end
function plugin.remove(context, packages) end
function plugin.update(context, packages) end
function plugin.list(context) end
function plugin.search(context, prompt) end
function plugin.info(context, packageName) end
```

Useful optional methods:

```lua
function plugin.init() end
function plugin.shutdown() end
function plugin.outdated(context) end
function plugin.resolvePackage(context, package) end
function plugin.resolveProxyRequest(context, request) end
function plugin.getSecurityMetadata() end
```

Optional metadata:

```lua
plugin.fileExtensions = { ".rpm", ".deb" }
```

## `context` Object

ReqPack passes `context` into action methods.

### Metadata

```lua
context.plugin.id
context.plugin.dir
context.plugin.script
context.plugin.bootstrap
context.flags
context.host
context.proxy
context.repositories
```

### Logging

```lua
context.log.debug("...")
context.log.info("...")
context.log.warn("...")
context.log.error("...")
```

### Transaction helpers

```lua
context.tx.status(42)
context.tx.progress(50)
context.tx.begin_step("install packages")
context.tx.commit()
context.tx.success()
context.tx.failed("install failed")
```

### Domain events

Use these to tell ReqPack what happened:

```lua
context.events.installed(payload)
context.events.deleted(payload)
context.events.updated(payload)
context.events.listed(payload)
context.events.searched(payload)
context.events.informed(payload)
context.events.outdated(payload)
context.events.unavailable(payload)
```

### Helpers

```lua
local result = context.exec.run("your-command --flag")
local tmpDir = context.fs.get_tmp_dir()
local ok = context.net.download(url, destination)
context.artifacts.register({ type = "file", path = "/tmp/out" })
```

Global helper also exists:

```lua
local result = reqpack.exec.run("command -v your-tool >/dev/null 2>&1")
local host = reqpack.host
```

Use `context.exec.run(...)` inside action methods when possible.

## Data You Usually Return

### `getMissingPackages(packages)`

Return only packages that still need work.

Examples:

- install: package not yet installed
- remove: package currently installed
- update: package has newer version available

Lazy `return packages` works, but planning quality gets worse.

### `list`, `search`, `outdated`

Return array of package info tables.

Common fields:

```lua
{
  name = "curl",
  version = "8.0.1",
  latestVersion = "8.1.0",
  type = "package",
  summary = "Transfer tool",
  description = "Longer description",
  architecture = "x86_64",
}
```

### `info`

Return one package info table.

## Typical Wrapper Pattern

Thin wrappers usually do this:

1. check installed state in `getMissingPackages()`
2. build shell command
3. run command with `context.exec.run(...)`
4. emit `context.tx.*` and `context.events.*`
5. return `true` or parsed package info

Example:

```lua
function plugin.install(context, packages)
    if #packages == 0 then
        return true
    end

    context.tx.begin_step("install packages")
    local result = context.exec.run("example-pm install ...")
    if not result.success then
        context.tx.failed("install failed")
        return false
    end

    context.events.installed(packages)
    context.tx.success()
    return true
end
```

## Testing

ReqPack has hermetic plugin tests.

```bash
rqp test-plugin --plugin ./your-plugin.lua --preset core
rqp test-plugin --plugin ./your-plugin.lua --case ./.reqpack-test/core/info.lua
```

Case files are Lua tables with:

- `request`
- `fakeExec`
- `expect`

Template already ships example cases.

## Best Practices

- Keep wrapper thin. Let real package manager do real work.
- Emit events for visible results.
- Add `installLocal()` if ecosystem supports local artifacts.
- Add `resolvePackage()` later if exact version lookup is possible.
- Keep command parsing deterministic.
- Start with template, then replace placeholders step by step.

## Full Docs

Read full wiki pages for details when working inside ReqPack repo:

- `ReqPack.wiki/Extending-ReqPack.md`
- `ReqPack.wiki/Extending-Writing-Lua-Plugins.md`
