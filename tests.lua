require "mustache"

tests = {
    { tem = "{{ foo }}", env = { foo = "foo" }, correct = "foo" },

    { tem = "{{ one }} != {{ two }}", env = { one = 1, two = 2 }, 
      correct = "1 != 2" },

    { tem = "fn call: {{ foo }}", env = { foo = function() return "return" end },
      correct = "fn call: return" },  

    { tem = "no tag", env = { }, correct = "no tag" },

    { tem = "no whitespace {{foo}}", env = { foo = "works" }, 
      correct = "no whitespace works" },

    { tem = "a comment {{! this is invisible }}", env = { },
      correct = "a comment " },

    { tem = "escaped: '{{ esc }}', unescaped: '{{& esc }}'", env = { 
      esc = "&" }, correct = "escaped: '&amp;', unescaped: '&'" },


--[[
    { tem = "{{#list}} name = {{ name }} {{/list}}", env = { list = {
      { name = "foo" }, { name = "bar" }, { name = "quux" } } },
      correct = " name = foo  name = bar  name = quux " },

    { tem = "{{#list}} name = {{ . }} {{/list}}", env = { list = {
      "foo", "bar", "quux" } },
      correct = " name = foo  name = bar  name = quux " },

    { tem = "{{ #bool }} maybe shown {{ /bool }}", env = { bool = true },
      correct = " maybe shown " },

    { tem = "{{ #list }} maybe shown {{ . }} {{ /list }}", env = { list = { } },
      correct = "" },

    { tem = {{ ^list }} list is empty! {{ /list }}", env = { list = { } },
      correct = " list is empty! " },
--]]

-- Add nested section test
-- Add "lambda/wrapped" test
-- Add multiline tests
}

for i, v in ipairs(tests) do
    print("\n== TEST: " .. i .. " ==")
    print("template =", "'" .. v.tem .. "'")
    ret = mustache.render(v.tem, v.env)
    print("render   =", "'" .. ret .. "'")
    assert(ret == v.correct)
end


print("\n--> All tests passed")
