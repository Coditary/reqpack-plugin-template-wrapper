plugin = {}

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

-- Put plugin identity and user-visible metadata here.
function plugin.getName()
    return "Template Wrapper"
end

function plugin.getVersion()
    return "0.1.0"
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
function plugin.install(context, packages)
    return true
end

-- Handle local files like .deb, .rpm, archives, or extracted dirs here.
function plugin.installLocal(context, path)
    return true
end

-- Build and run remove command here.
function plugin.remove(context, packages)
    return true
end

-- Build and run update command here.
function plugin.update(context, packages)
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
function plugin.init()
    return true
end

function plugin.shutdown()
    return true
end

return plugin
