local fs = zune.fs
local luau = zune.luau

local moduleCache = {}

local function resolvePath(baseDir: string, target: string): string
    if not target:find("^%.") then
        return target
    end

    local segments = baseDir:split("/")
    if segments[#segments] == "" then table.remove(segments) end

    for _, segment in target:split("/") do
        if segment == ".." then
            table.remove(segments)
        elseif segment ~= "." and segment ~= "" then
            table.insert(segments, segment)
        end
    end

    return table.concat(segments, "/")
end

local function loadModule(path: string): any
    local cleanPath = path:gsub("%.luau$", ""):gsub("%.lua$", "")
    local fullPath = cleanPath .. ".luau"

    if moduleCache[fullPath] then
        return moduleCache[fullPath]
    end

    local readSuccess, source = pcall(fs.readFile, fullPath)
    if not readSuccess then
        error(`File not found: {fullPath}`)
    end

    local bytecode = luau.compile(source)

    local env = {
        require = function(targetPath: string)
            if targetPath:sub(1, 1) == "." then
                local currentDir = fullPath:match("(.*[/\\])") or "./"
                local resolved = resolvePath(currentDir, targetPath)
                return loadModule(resolved)
            end
            
            return require(targetPath) :: any
        end
    }

    local fn = luau.load(bytecode, {
        debugName = fullPath,
        environment = env,
        injectGlobals = true,
    })

    local success, result = pcall(fn)
    if not success then
        error(`Failed to load module '{fullPath}':\n{result}`)
    end

    moduleCache[fullPath] = result
    return result
end

return loadModule