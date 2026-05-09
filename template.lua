plugin = {}

-- Replace these values first.
local PLUGIN_NAME = "Template Wrapper"
local PLUGIN_VERSION = "0.1.0"
local REQUIRED_BINARY = ""

-- Convert this template in this order:
-- 1. rename file to <plugin-id>.lua
-- 2. replace all "template" placeholders
-- 3. add binary check in bootstrap() or init()
-- 4. replace safe placeholder behavior with real package-manager commands
-- 5. update .reqpack-test/core/*.lua to match real behavior

local function trim(value)
    return (tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function shell_quote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function emit_event(context, name, payload)
    if context == nil or context.events == nil then
        return
    end

    local fn = context.events[name]
    if type(fn) == "function" then
        fn(payload)
    end
end

local function begin_step(context, label)
    if context == nil or context.tx == nil then
        return
    end

    local fn = context.tx.begin_step
    if type(fn) == "function" then
        fn(label)
    end
end

local function tx_success(context)
    if context == nil or context.tx == nil then
        return
    end

    local fn = context.tx.success
    if type(fn) == "function" then
        fn()
    end
end

local function command_exists(binary)
    return reqpack.exec.run("command -v " .. shell_quote(binary) .. " >/dev/null 2>&1").success
end

plugin.fileExtensions = {}

-- Put plugin identity and user-visible metadata here.
function plugin.getName()
    return PLUGIN_NAME
end

function plugin.getVersion()
    return PLUGIN_VERSION
end

-- Return external tools or bootstrap dependencies if plugin needs them.
function plugin.getRequirements()
    return {}
end

function plugin.getCategories()
    return { "Template", "Wrapper" }
end

-- Return packages that still need action.
-- Replace this with real installed-state checks later.
function plugin.getMissingPackages(packages)
    return packages or {}
end

-- Build and run package-manager install command here.
-- Typical flow: begin step -> run command -> emit installed -> tx.success.
function plugin.install(context, packages)
    begin_step(context, "install template packages")
    emit_event(context, "installed", packages or {})
    tx_success(context)
    return true
end

-- Handle local files like .deb, .rpm, archives, or extracted dirs here.
function plugin.installLocal(context, path)
    begin_step(context, "install local template artifact")
    emit_event(context, "installed", { path = path, localTarget = true })
    tx_success(context)
    return true
end

-- Build and run remove command here.
function plugin.remove(context, packages)
    begin_step(context, "remove template packages")
    emit_event(context, "deleted", packages or {})
    tx_success(context)
    return true
end

-- Build and run update command here.
function plugin.update(context, packages)
    begin_step(context, "update template packages")
    emit_event(context, "updated", packages or {})
    tx_success(context)
    return true
end

-- Return installed packages as array of tables.
function plugin.list(context)
    local items = {}
    emit_event(context, "listed", items)
    return items
end

-- Return only packages with updates available.
function plugin.outdated(context)
    local items = {}
    emit_event(context, "outdated", items)
    return items
end

-- Query remote/local package source here.
function plugin.search(context, prompt)
    if trim(prompt) == "" then
        local empty = {}
        emit_event(context, "searched", empty)
        return empty
    end

    local items = {
        {
            name = trim(prompt),
            version = "template",
            type = "package",
            summary = "Replace this placeholder search result",
        }
    }

    emit_event(context, "searched", items)
    return items
end

-- Return one package record with details for `rqp info`.
function plugin.info(context, name)
    local item = {
        name = trim(name) ~= "" and trim(name) or "template-package",
        version = "template",
        description = "Replace this placeholder info result",
    }

    emit_event(context, "informed", item)
    return item
end

-- Check whether required binaries or environment are ready.
-- Set REQUIRED_BINARY above if plugin needs one CLI tool available.
function plugin.init()
    if REQUIRED_BINARY ~= "" then
        return command_exists(REQUIRED_BINARY)
    end
    return true
end

function plugin.shutdown()
    return true
end

return plugin
