--
-- mustache.lua
--
-- external function: render(template, environment)
--

module(..., package.seeall);

DEBUG = false
--DEBUG = true


---------------------
-- pattern section --
---------------------

otag = "{{"
ctag = "}}"

-- tag modifiers: '&'=no escape, '!'=comment, '{'=no escape
-- not implemented: '='=change delimiter, '>'=partials
tag_pattern = "(" .. otag .. "%s*([&!{=>]?)%s*([^}]+)%s*}?" .. ctag .. ")"

-- sect modifiers: '#'=open, '/'=close, '^'=invert
sect_pattern = "(" .. otag .. "%s*([#^])%s*([^}]+)%s*}?" .. ctag ..  "(%s*.*%s*)" .. 
               otag .. "%s*/%s*[^}]+%s*}?" .. ctag ..")"


--------------------
-- util functions --
--------------------

-- print debug messages
local function debug(...) if DEBUG then print(...) end end

-- remove whitespace at the beginning and end of a string
local function trim(s) return (s:gsub("^%s*(.-)%s*$", "%1")) end

-- escape characters '&', '>' and '<' for HTML
local function escape(s)
    if type(s) ~= 'string' then return s end
    return (s:gsub('&', '&amp;'):gsub('>', '&gt;'):gsub('<', '&lt;'))
end

-- finds a tag in an environment; functions are called
local function get_variable(tag, env)
    if type(env[tag]) == 'function' then return env[tag]() end
    if env[tag] ~= nil              then return env[tag]   end
    return ''
end

-- determine if a table is being used as a dictionary
--   - somewhat hackish, but if a table has any numeric keys it is
--     determined to not be a dictionary
--   - a table with no keys at all is not considered a dictionary
function is_dict(t)
    if type(t) ~= 'table' then return false end
    keycount = 0
    for k, v in pairs(t) do
        keycount = keycount + 1
        if type(k) == 'number' then return false end
    end
    if keycount == 0 then return false end
    return true
end


-----------------------------
-- tag rendering functions --
-----------------------------

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

---------------------------------
-- overall rendering functions --
---------------------------------

local function render_tags(template, env)
    while true do
        local _, _, tag, tagmod, tagname = template:find(tag_pattern)

        -- break if we haven't found any tags
        if _ == nil then break end
        tagname = trim(tagname)

        debug("[debug-loop]", "template = ", "'"..template.."'")
        debug("[debug-loop]", "tag      = ", "'"..tag.."'")
        debug("[debug-loop]", "tagmod   = ", "'"..tagmod.."'")
        debug("[debug-loop]", "tagname  = ", "'"..tagname.."'")

        replacement = modifiers[tagmod](tagname, env)
        debug("[debug-loop]", "replace  = ", "'"..replacement.."'")
        template = template:gsub(tag, replacement)
    end
    return template
end

local function render_sections(template, env)
    while true do
        local _, _, tag, tagmod, tagname, content = template:find(sect_pattern)

        if _ == nil then break end
        tagname = trim(tagname)
        tagmod = trim(tagmod)

        debug("[debug-loop]", "template = ", "'"..template.."'")
        debug("[debug-loop]", "tag      = ", "'"..tag.."'")
        debug("[debug-loop]", "tagmod   = ", "'"..tagmod.."'")
        debug("[debug-loop]", "tagname  = ", "'"..tagname.."'")
        debug("[debug-loop]", "content  = ", "'"..content.."'")

        val = env[tagname]
        replacement = ''

        -- handle false values and tag not found
        if val == nil or val == false then
            debug("[debug-sect]", "found: ", "nil or false value")
            if tagmod == '^' then replacement = content
            else replacement = '' end
        -- handle non empty lists
        elseif type(val) == 'table' and #val ~= 0 then
            debug("[debug-sect]", "found: ", "non-empty list found")
            filler = {}
            for i, v in ipairs(val) do
                debug("[debug-sect]", "rendering: ", v)
                table.insert(filler, render(content, v))
            end
            replacement = table.concat(filler)
        -- handle dictionaries
        elseif type(val) == 'table' and is_dict(val) then
            debug("[debug-sect]", "found: ", "dictionary found")
            replacement = render(content, val)
        -- handle empty lists
        elseif type(val) == 'table' and #val == 0 and not is_dict(val) then
            debug("[debug-sect]", "found: ", "empty list found")
            if tagmod == '^' then replacement = content
            else replacement = '' end
        -- handle lambdas / wrappers
        elseif type(val) == 'function' then
            debug("[debug-sect]", "found: ", "function found")
            replacement = val(content)
        -- handle other non-false values
        elseif val then
            debug("[debug-sect]", "found: ", "other value found")
            if tagmod == '^' then replacement = ''
            else replacement = content end
        end
    
        debug("[debug-loop]", "replace  = ", "'"..replacement.."'")

        template = template:gsub(tag, replacement)
        break
    end
    return template
end

function render(template, env)
    debug("[debug]", "render called")
    debug("[debug]", "template = ", "'"..template.."'")
    env = env or {}

    template = render_sections(template, env)
    template = render_tags(template, env)

    return template
end
