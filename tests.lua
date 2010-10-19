require "mustache"

template = "{{ foo }}"
env = { foo = "foo" }
print("== TEST 1 ==")
print("template =", "'" .. template .. "'")
ret = mustache.render(template, env)
print("render   =", "'" .. ret .. "'")
assert(ret == 'foo')
---------------------------------------------------------------------
template = "{{ one }} != {{ two }}"
env = { one = 1, two = 2 }
print("\n== TEST 2 ==")
print("template =", "'" .. template .. "'")
ret = mustache.render(template, env)
print("render   =", "'" .. ret .. "'")
assert(ret == '1 != 2')
---------------------------------------------------------------------
template = "function: {{ foo }}"
env = { foo = function() return "value returned" end }
print("\n== TEST 3 ==")
print("template =", "'" .. template .. "'")
ret = mustache.render(template, env)
print("render   =", "'" .. ret .. "'")
assert(ret == 'function: value returned')
---------------------------------------------------------------------
template = "no tag"
env = {}
print("\n== TEST 4 ==")
print("template =", "'" .. template .. "'")
ret = mustache.render(template, env)
print("render   =", "'" .. ret .. "'")
assert(ret == 'no tag')
---------------------------------------------------------------------
template = "no whitespace {{foo}}"
env = { foo = "works" }
print("\n== TEST 5 ==")
print("template =", "'" .. template .. "'")
ret = mustache.render(template, env)
print("render   =", "'" .. ret .. "'")
assert(ret == 'no whitespace works')
---------------------------------------------------------------------
template = "a comment {{! this is invisible }}"
env = {}
print("\n== TEST 6 ==")
print("template =", "'" .. template .. "'")
ret = mustache.render(template, env)
print("render   =", "'" .. ret .. "'")
assert(ret == 'a comment ')
---------------------------------------------------------------------
print("\n--> All tests passed")
