--- message: send message to std_error
-- @param type string INFO, WARNING, ERROR
-- @param text string text of the message
function message(type, text)

    local level = {
        INFO = 0,
        WARNING = 1,
        ERROR = 2
    }

    if level[type] == nil then type = 'ERROR' end

    if level[PANDOC_STATE.verbosity] <= level[type] then
        io.stderr:write('[' .. type .. '] Lua filter: ' .. text .. '\n')
    end

end