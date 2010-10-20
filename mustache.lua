--
-- mustache.lua
--
-- external function: render(template, environment)
--

module(..., package.seeall);

--DEBUG = false
DEBUG = true


--
-- pattern section
--

otag = "{{"
ctag = "}}"

-- tag modifiers: '&'=no escape, '!'=comment, '{'=no escape
-- not implemented: '='=change delimiter, '>'=partials
tag_pattern = "(" .. otag .. "%s*([&!{=>]?)%s*([^}]+)%s*}?" .. ctag .. ")"

-- sect modifiers: '#'=open, '/'=close, '^'=invert
sect_pattern = "(" .. otag .. "%s*[#^]%s*([^}]+)%s*}?" .. ctag ..  "%s*(.*)%s*" .. 
               otag .. "%s*/%s*[^}]+%s*}?" .. ctag ..")"


--
-- util functions
--

-- print debug messages
local function debug(...) if DEBUG then print(...) end end

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

-- escape characters '&', '>' and '<' for HTML
local function escape(s)
    return (s:gsub('&', '&amp;'):gsub('>', '&gt;'):gsub('<', '&lt;'))
end

-- finds a tag in an environment; functions are called
local function get_variable(tag, env)
    if type(env[tag]) == 'function' then return env[tag]() end
    if type(env[tag]) ~= 'nil' then return env[tag] end
    return ''
end


--
-- tag rendering functions
--

function render_normal(tag, env)
    debug("[debug]", "normal tag found")
    return escape(get_variable(tag, env))
end

local function render_comment(tag, env)
    debug("[debug]", "comment tag found")
    return ''
end

local function render_unescaped(tag, env)
    debug("[debug]", "unescaped tag found")
    return get_variable(tag, env)
end

local function render_partial(tag, env)
    debug("[debug-error]", "partials not implemented")
    return ''
end

local function render_change_delim(tag, env)
    debug("[debug-error]", "change delimiter not implemented")
    return ''
end

modifiers = { [""]  = render_normal
            , ["!"] = render_comment
            , ["&"] = render_unescaped
            , ["{"] = render_unescaped
            , [">"] = render_partial
            , ["="] = render_change_delim
}

--
-- overall rendering functions
--

-- render single tags
local function render_tags(template, env)
    while true do
        tagstart, tagend, tag, tagmod, tagname = template:find(tag_pattern)

        if tagstart == nil then break end
        tagname = trim(tagname)

        debug("[debug-loop]", "tagstart = ", tagstart)
        debug("[debug-loop]", "tagend   = ", tagend)
        debug("[debug-loop]", "tag      = ", "'"..tag.."'")
        debug("[debug-loop]", "tagmod   = ", "'"..tagmod.."'")
        debug("[debug-loop]", "tagname  = ", "'"..tagname.."'")
        debug("[debug-loop]", "template = ", "'"..template.."'")

        replacement = modifiers[tagmod](tagname, env)
        debug("[debug-loop]", "replace  = ", "'"..replacement.."'")

        template = template:gsub(tag, replacement)
        debug("[debug-loop]", "template = ", "'"..template.."'")
    end
    
    return template
end

local function render_sections(template, env)
    local ret = ""

    while true do
        tagstart, tagend, tag, tagname, content = template:find(sect_pattern)

        if tagstart == nil then
            ret = ret .. template
            break
        end
        tagname = trim(tagname)

        debug("[debug-loop]", "tagstart = ", tagstart)
        debug("[debug-loop]", "tagend   = ", tagend)
        debug("[debug-loop]", "tag      = ", "'"..tag.."'")
        debug("[debug-loop]", "tagname  = ", "'"..tagname.."'")
        debug("[debug-loop]", "content  = ", "'"..content.."'")

        template, ret = eat(tagstart, template, ret)
        debug("[debug-loop]", "template = ", "'"..template.."'")
        debug("[debug-loop]", "ret      = ", "'"..ret.."'")

        val = env[tagname]
        

        break
    end
        
    return ret
end

function render(template, env)
    local env = env or {}

    --template = render_sections(template, env)
    return render_tags(template, env)
end
