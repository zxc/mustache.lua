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
      correct = "a comment "}
}

for i, v in ipairs(tests) do
    print("\n== TEST: " .. i .. " ==")
    print("template =", "'" .. v.tem .. "'")
    ret = mustache.render(v.tem, v.env)
    print("render   =", "'" .. ret .. "'")
    assert(ret == v.correct)
end


print("\n--> All tests passed")
