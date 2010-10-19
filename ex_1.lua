require "mustache"

template = "Hello, {{ what }}"
env = { what='world' }

print("Template:", template)
print("Rendered:", mustache.render(template, env))
