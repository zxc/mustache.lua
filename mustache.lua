--
-- mustache.lua
--
-- external function: render(template, environment)
--

module(..., package.seeall);

DEBUG = false

otag = "{{"
ctag = "}}"

-- tag modifiers: '&'=no escape, '!'=comment, '{'=no escape
-- not implemented: '='=change delimiter, '>'=partials
tag_pattern = "(" .. otag .. "%s*([&!{]?)%s*([^}]+)%s*}?" .. ctag .. ")"

-- sect modifiers: '#'=open, '/'=close, '^'=invert
local sect_pattern = "(" .. otag .. ""

-- print debug messages
local function debug(...)
    if DEBUG then print(...) end
end

-- delete from a string, and optionally append to another
local function eat(amt, src, dest)
    if dest then dest = dest .. src:sub(0, amt - 1) end
    src = src:sub(amt, -1)

    if dest then return src, dest end
    return src
end

-- remove whitespace at the beginning and end of a string
local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- render single tags
local function render_tags(template, env)
    local ret = ""

    while true do
        tagstart, tagend, tag, tagmod, tagname = template:find(tag_pattern)

        if tagstart == nil then 
            ret = ret .. template
            break 
        end
        tagname = trim(tagname)

        debug("[debug-loop]", "tagstart = ", tagstart)
        debug("[debug-loop]", "tagend   = ", tagend)
        debug("[debug-loop]", "tag      = ", "'"..tag.."'")
        debug("[debug-loop]", "tagmod   = ", "'"..tagmod.."'")
        debug("[debug-loop]", "tagname  = ", "'"..tagname.."'")

        template, ret = eat(tagstart, template, ret)

        debug("[debug-loop]", "template = ", "'"..template.."'")
        debug("[debug-loop]", "ret      = ", "'"..ret.."'")

        if tagmod == '' then
            if env[tagname] then
                if type(env[tagname]) == 'function' then
                    ret = ret .. env[tagname]()
                else
                    ret = ret .. env[tagname]
                end
            end
        end

        template = eat(tagend - tagstart + 2, template)

        debug("[debug-loop]", "template = ", "'"..template.."'")
        debug("[debug-loop]", "ret      = ", "'"..ret.."'")

    end

    return ret

end

local function render_sections(template, env)
    return template
end

function render(template, env)
    local env = env or {}

    template = render_sections(template, env)
    return render_tags(template, env)
end
