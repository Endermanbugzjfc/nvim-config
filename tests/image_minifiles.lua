-- Run: LANG=en_US NVIM_LOG_FILE=/tmp/image-minifiles.log nvim -n --headless -u NONE -i NONE -l tests/image_minifiles.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/image.nvim")

-- Load the real image.nvim autocommands through our plugin configuration.
package.loaded.python_images = { setup = function() end }
for _, spec in ipairs(require "plugins") do
  if spec[1] == "3rd/image.nvim" then
    local opts = vim.deepcopy(spec.opts)
    for _, name in ipairs { "markdown", "asciidoc", "typst", "neorg", "syslang" } do
      opts.integrations[name] = { enabled = false }
    end
    spec.config(nil, opts)
  end
end

local function open_preview(path)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, "minifiles://" .. buf .. "/" .. path)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "preview content" })
  vim.bo[buf].modifiable = false
  local win = vim.api.nvim_open_win(buf, false, {
    relative = "editor", row = 1, col = 1, width = 30, height = 2,
  })
  assert(vim.bo[buf].buftype == "nofile", "image.nvim changed preview buftype")
  assert(vim.bo[buf].filetype ~= "image_nvim", "image.nvim hijacked preview")
  assert(vim.api.nvim_buf_get_lines(buf, 0, -1, false)[1] == "preview content")
  vim.api.nvim_win_close(win, true)
  vim.api.nvim_buf_delete(buf, { force = true })
end

local root = vim.fn.tempname()
vim.fn.mkdir(root, "p")
for _, extension in ipairs { "png", "jpg", "jpeg", "gif", "webp", "avif" } do
  local path = root .. "/test." .. extension
  open_preview(path) -- A newly typed name, before synchronization.
  vim.fn.writefile({ "fixture" }, path)
  open_preview(path) -- An existing file still has a virtual preview buffer.
end

-- Ordinary image buffers must still reach the renderer. Stub only decoding
-- and terminal rendering, which cannot be checked in a headless session.
local rendered_path
require("image").from_file = function(path)
  rendered_path = path
end
local path = root .. "/test.png"
vim.cmd.edit(vim.fn.fnameescape(path))
assert(rendered_path == path, "ordinary image file no longer reaches image.nvim")
assert(vim.bo.filetype == "image_nvim")
vim.fn.delete(root, "rf")
print "PASS: mini.files previews stay intact for all image extensions; ordinary image files still reach the renderer"
