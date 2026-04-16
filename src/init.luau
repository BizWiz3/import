local Types = require("@self/types")

local function getAdapter(): Types.Import
    local runtime = string.split(_VERSION, " ")[1]:lower()

    if runtime == "lune" then
        return require("@self/lune")
    elseif runtime == "zune" then
        return require("@self/zune")
    else
        error(`Unsupported Runtime: "{runtime}"`)
    end
end

return getAdapter()
