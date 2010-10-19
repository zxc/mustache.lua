
module(..., package.seeall);

otag = "{{"
ctag = "}}"

tag_pattern = "(" .. otag .. "%s*([#{^]?)%s*(%w+)%s*}?" .. ctag .. ")"

tests = { "basic: {{ foo }}"
        , "modifier: {{ #foo }}"
        , "modifier: {{#foo}}"
        , "modifier: {{ ^foo }}"
        }

function do_tests()
    for i, v in ipairs(tests) do
        print("test: " .. i, "'" .. v .. "'")
        print(v:find(tag_pattern))
    end
end

function render(template, env)
    local env = env or {}

    print("[debug]", "template = ", template)
    print("[debug]", "environment = ", env)

    local ret = ""

    while true do
        print("[debug-loop]", "START LOOP")
        tagstart, tagend, tag, tagmod, tagname = template:find(tag_pattern)

        if tagstart == nil then 
            ret = ret .. template
            break 
        end
        print("[debug-loop]", "tagstart = ", tagstart)
        print("[debug-loop]", "tagend   = ", tagend)
        print("[debug-loop]", "tag      = ", "'"..tag.."'")
        print("[debug-loop]", "tagmod   = ", "'"..tagmod.."'")
        print("[debug-loop]", "tagname  = ", "'"..tagname.."'")

        template, ret = eat(tagstart, template, ret)
        print("[debug-loop]", "template = ", "'"..template.."'")
        print("[debug-loop]", "ret      = ", "'"..ret.."'")

        if env[tagname] then
            if type(env[tagname]) == 'function' then
                ret = ret .. env[tagname]()
            else
                ret = ret .. env[tagname]
            end
        end

        template = eat(tagend - tagstart + 2, template)
        print("[debug-loop]", "template = ", "'"..template.."'")
        print("[debug-loop]", "ret      = ", "'"..ret.."'")
    end

    return ret
end

function eat(amt, src, dest)
    if dest then dest = dest .. src:sub(0, amt - 1) end
    src = src:sub(amt, -1)

    if dest then return src, dest end
    return src
end
