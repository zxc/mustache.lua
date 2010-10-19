--
-- mustache.lua
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

local function eat(amt, src, dest)
    if dest then dest = dest .. src:sub(0, amt - 1) end
    src = src:sub(amt, -1)

    if dest then return src, dest end
    return src
end

local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function render_tags(template, env)
    local ret = ""

    while true do
        tagstart, tagend, tag, tagmod, tagname = template:find(tag_pattern)

        if tagstart == nil then 
            ret = ret .. template
            break 
        end
        tagname = trim(tagname)

if DEBUG then
    print("[debug-loop]", "tagstart = ", tagstart)
    print("[debug-loop]", "tagend   = ", tagend)
    print("[debug-loop]", "tag      = ", "'"..tag.."'")
    print("[debug-loop]", "tagmod   = ", "'"..tagmod.."'")
    print("[debug-loop]", "tagname  = ", "'"..tagname.."'")
end

        template, ret = eat(tagstart, template, ret)

if DEBUG then
    print("[debug-loop]", "template = ", "'"..template.."'")
    print("[debug-loop]", "ret      = ", "'"..ret.."'")
end

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

if DEBUG then
    print("[debug-loop]", "template = ", "'"..template.."'")
    print("[debug-loop]", "ret      = ", "'"..ret.."'")
end

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
