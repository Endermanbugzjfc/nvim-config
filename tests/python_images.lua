-- Run: NVIM_LOG_FILE=/tmp/python-images.log nvim -n --headless -u NONE -i NONE -l tests/python_images.lua
package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. package.path

local state = { images = {} }
local created, rendered, cleared = 0, 0, 0
package.loaded.image = {
  from_file = function(path, opts)
    if state.images[opts.id] then
      return state.images[opts.id]
    end
    created = created + 1
    local image = {
      id = opts.id,
      original_path = path,
      buffer = opts.buffer,
      window = opts.window,
      global_state = state,
      geometry = { x = opts.x, y = opts.y, width = opts.width, height = opts.height },
    }
    function image:render()
      rendered = rendered + 1
      state.images[self.id] = self
    end
    function image:clear()
      cleared = cleared + 1
      -- image.nvim's clear deliberately retains the image in its registry.
    end
    function image:move(x, y)
      self.geometry.x, self.geometry.y = x, y
      self:render()
    end
    assert(opts.inline and opts.with_virtual_padding)
    return image
  end,
}

local root = vim.fn.tempname()
vim.fn.mkdir(root .. "/assets", "p")
vim.fn.writefile({ "fixture" }, root .. "/assets/a.png")
vim.fn.writefile({ "fixture" }, root .. "/assets/b.png")
local buffer = vim.api.nvim_get_current_buf()
vim.api.nvim_buf_set_name(buffer, root .. "/example.py")
local function lines(content)
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, content)
end
local function images()
  local result = vim.tbl_values(state.images)
  table.sort(result, function(a, b)
    return a.geometry.y < b.geometry.y
  end)
  return result
end
local function counts(c, r, cl)
  assert(created == c, ("created %d, expected %d"):format(created, c))
  assert(rendered == r, ("rendered %d, expected %d"):format(rendered, r))
  assert(cleared == cl, ("cleared %d, expected %d"):format(cleared, cl))
end

lines {
  "# image.nvim: path=./assets/a.png",
  "# image.nvim: path=./assets/a.png width=40",
  "# image.nvim: path=./assets/a.png height=20",
  "# image.nvim: height=15 path=./assets/a.png width=30",
  'text = "# image.nvim: path=./assets/a.png"',
  "# image.nvim: path=./assets/missing.png",
  "# image.nvim: path=./assets/a.png width=0",
  "# image.nvim: path=./assets/a.png height=nope",
  "# image.nvim: path=./assets/a.png width=10 width=20",
  "value = 1",
}
local renderer = require "python_images"
renderer.setup()
assert(vim.wait(500, function() return created == 4 end))
counts(4, 4, 0)
local original = images()
assert(original[1].geometry.width == nil and original[1].geometry.height == nil)
assert(original[2].geometry.width == 40 and original[2].geometry.height == nil)
assert(original[3].geometry.width == nil and original[3].geometry.height == 20)
assert(original[4].geometry.width == 30 and original[4].geometry.height == 15)
assert(original[1].original_path == root .. "/assets/a.png")

-- Unrelated edits and scrolls do not clear, create, or render any images.
vim.api.nvim_buf_set_lines(buffer, 9, 10, false, { "value = 2" })
renderer.render(buffer)
vim.api.nvim_exec_autocmds("WinScrolled", { pattern = tostring(vim.api.nvim_get_current_win()) })
vim.wait(150, function() return false end)
counts(4, 4, 0)

-- Resetting a dimension to nil works without constructing another image.
vim.api.nvim_buf_set_lines(buffer, 1, 2, false, { "# image.nvim: path=./assets/a.png height=25" })
renderer.render(buffer)
counts(4, 5, 1)
assert(original[2].geometry.width == nil and original[2].geometry.height == 25)
renderer.render(buffer)
counts(4, 5, 1)

-- Inserting above a declaration preserves its identity and moves its position.
vim.api.nvim_buf_set_lines(buffer, 0, 0, false, { "# heading" })
renderer.render(buffer)
counts(4, 9, 1)
assert(images()[1] == original[1] and original[1].geometry.y == 1)
-- If image.nvim already moved an image, the integration does no extra render.
vim.api.nvim_buf_set_lines(buffer, 0, 0, false, { "# another heading" })
for _, image in ipairs(images()) do
  image.geometry.y = image.geometry.y + 1
end
renderer.render(buffer)
counts(4, 9, 1)

-- Path changes replace only the affected image; deleted images leave no registry ghosts.
vim.api.nvim_buf_set_lines(buffer, 2, 3, false, { "# image.nvim: path=" .. root .. "/assets/b.png" })
renderer.render(buffer)
counts(5, 10, 2)
assert(state.images[original[1].id] == nil)
assert(images()[1].original_path == root .. "/assets/b.png")
vim.api.nvim_buf_set_lines(buffer, 2, 3, false, { "# removed" })
renderer.render(buffer)
counts(5, 10, 3)
assert(#images() == 3)

-- Bursts of edits wait until the debounce expires and apply only the final geometry.
for width = 41, 43 do
  vim.api.nvim_buf_set_lines(buffer, 3, 4, false, { "# image.nvim: path=./assets/a.png width=" .. width })
  vim.api.nvim_exec_autocmds("TextChangedI", { buffer = buffer })
end
counts(5, 10, 3)
assert(vim.wait(500, function() return rendered == 11 end))
counts(5, 11, 4)
assert(original[2].geometry.width == 43 and original[2].geometry.height == nil)

-- A split gets its own image objects, and closing it unregisters only those objects.
vim.cmd "split"
renderer.render(buffer)
counts(8, 14, 4)
vim.cmd "close"
counts(8, 14, 7)
assert(#images() == 3)

-- Buffer deletion cancels deferred edits and removes every remaining image.
vim.api.nvim_exec_autocmds("TextChanged", { buffer = buffer })
vim.api.nvim_buf_delete(buffer, { force = true })
vim.wait(150, function() return false end)
counts(8, 14, 10)
assert(next(state.images) == nil)
print "PASS: optional dimensions, image reuse, movement, debounce, scroll, path edits, split and buffer cleanup"
