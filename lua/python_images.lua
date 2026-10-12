local M = {}

local api = require "image"
local namespace = "python-images"
local image_cache = {}
local pending = {}

local function clear(buffer)
  for _, image in pairs(image_cache[buffer] or {}) do
    image:clear()
  end
  image_cache[buffer] = nil
end

local function parse_image_line(line)
  local path, width, height = line:match "^%s*#%s*image%.nvim:%s*path=(%S+)%s+width=(%d+)%s+height=(%d+)%s*$"
  if not path then
    return nil
  end
  width, height = tonumber(width), tonumber(height)
  if width == 0 or height == 0 then
    return nil
  end
  return { path = path, width = width, height = height }
end

local function resolve_path(buffer, path)
  if path:sub(1, 1) == "/" then
    return path
  end
  local directory = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buffer), ":h")
  return vim.fn.fnamemodify(directory .. "/" .. path, ":p")
end

function M.render(buffer)
  buffer = buffer or vim.api.nvim_get_current_buf()
  clear(buffer)
  if not vim.api.nvim_buf_is_valid(buffer) or not vim.api.nvim_buf_is_loaded(buffer) then
    return
  end

  local window = vim.fn.bufwinid(buffer)
  if window == -1 then
    return
  end
  image_cache[buffer] = {}

  for row, line in ipairs(vim.api.nvim_buf_get_lines(buffer, 0, -1, false)) do
    local spec = parse_image_line(line)
    if spec then
      local path = resolve_path(buffer, spec.path)
      if vim.fn.filereadable(path) == 1 then
        -- image.nvim retains cleared objects by ID; include the declaration so edits get fresh options.
        local id = table.concat({ namespace, buffer, window, row, path, spec.width, spec.height }, ":")
        local ok, image = pcall(api.from_file, path, {
          id = id,
          window = window,
          buffer = buffer,
          inline = true,
          with_virtual_padding = true,
          width = spec.width,
          height = spec.height,
          x = 0,
          y = row - 1,
          namespace = namespace,
        })
        if ok and image then
          image_cache[buffer][id] = image
          image:render()
        end
      end
    end
  end
end

local function schedule_render(buffer)
  if pending[buffer] then
    return
  end
  pending[buffer] = true
  vim.schedule(function()
    pending[buffer] = nil
    if vim.api.nvim_buf_is_valid(buffer) then
      M.render(buffer)
    end
  end)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("python-images", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "TextChanged", "TextChangedI" }, {
    group = group,
    pattern = "*.py",
    callback = function(args)
      schedule_render(args.buf)
    end,
  })
  -- WinScrolled matches window IDs, not filenames.
  vim.api.nvim_create_autocmd("WinScrolled", {
    group = group,
    callback = function(args)
      local window = tonumber(args.match)
      if window and vim.api.nvim_win_is_valid(window) then
        local buffer = vim.api.nvim_win_get_buf(window)
        if vim.api.nvim_buf_get_name(buffer):match "%.py$" then
          schedule_render(buffer)
        end
      end
    end,
  })
  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = group,
    callback = function(args)
      clear(args.buf)
    end,
  })

  local buffer = vim.api.nvim_get_current_buf()
  if vim.api.nvim_buf_get_name(buffer):match "%.py$" then
    schedule_render(buffer)
  end
end

return M
