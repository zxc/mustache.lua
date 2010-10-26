
require "mustache"

env = {
    template_engine = "mustache.lua",

    details = { string_fn = "render()", file_fn = "renderfile()" },

    numbers = { { num = 1 }, { num = 2 }, { num = 3 } },

    done = true
}

print(mustache.renderfile("example.mustache", env))
