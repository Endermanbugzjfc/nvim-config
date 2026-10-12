local M = {}

local api = require "image"
local namespace = "python-images"
local anchors = vim.api.nvim_create_namespace(namespace)
local image_cache = {}
local pending = {}
local next_id = 0

local function dispose(image)
  image:clear()
  -- clear() only hides an image. The pinned image.nvim has no public disposal API;
  -- unregister it so its scroll/resize handlers cannot resurrect removed declarations.
  image.global_state.images[image.id] = nil
end

local function remove_entry(buffer, entry)
  for _, image in pairs(entry.images) do
    dispose(image)
  end
  if vim.api.nvim_buf_is_valid(buffer) then
    vim.api.nvim_buf_del_extmark(buffer, anchors, entry.anchor)
  end
end

local function clear(buffer)
  pending[buffer] = nil
  for _, entry in ipairs(image_cache[buffer] or {}) do
    remove_entry(buffer, entry)
  end
  image_cache[buffer] = nil
end

local function parse_image_line(line)
  local declaration = line:match "^%s*#%s*image%.nvim:%s*(.-)%s*$"
  if not declaration then
    return nil
  end
  local spec = {}
  for token in declaration:gmatch "%S+" do
    local key, value = token:match "^(%a+)=(%S+)$"
    if not key or spec[key] ~= nil then
      return nil
    end
    if key == "path" then
      spec.path = value
    elseif key == "width" or key == "height" then
      if not value:match "^%d+$" or tonumber(value) <= 0 then
        return nil
      end
      spec[key] = tonumber(value)
    else
      return nil
    end
  end
  return spec.path and spec or nil
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
  if not vim.api.nvim_buf_is_valid(buffer) or not vim.api.nvim_buf_is_loaded(buffer) then
    clear(buffer)
    return
  end

  local windows = vim.fn.win_findbuf(buffer)
  local visible = {}
  for _, window in ipairs(windows) do
    visible[window] = true
  end

  -- Our anchors also track declarations whose images are offscreen and have no padding extmark yet.
  local previous = image_cache[buffer] or {}
  local by_row = {}
  for _, entry in ipairs(previous) do
    local position = vim.api.nvim_buf_get_extmark_by_id(buffer, anchors, entry.anchor, {})
    if #position > 0 then
      by_row[position[1]] = by_row[position[1]] or {}
      table.insert(by_row[position[1]], entry)
    end
  end

  local current, kept = {}, {}
  for row, line in ipairs(vim.api.nvim_buf_get_lines(buffer, 0, -1, false)) do
    local spec = parse_image_line(line)
    if spec then
      local path = resolve_path(buffer, spec.path)
      local candidates = by_row[row - 1] or {}
      local entry
      for _, candidate in ipairs(candidates) do
        if candidate.path == path and not kept[candidate] then
          entry = candidate
          break
        end
      end
      if not entry then
        next_id = next_id + 1
        entry = {
          id = next_id,
          path = path,
          images = {},
        }
      end
      -- Anchor at the end of the comment: insertion above moves it, while a whole-line
      -- replacement leaves it on the edited line rather than the following declaration.
      entry.anchor = vim.api.nvim_buf_set_extmark(buffer, anchors, row - 1, #line, {
        id = entry.anchor,
        right_gravity = false,
      })
      entry.width, entry.height = spec.width, spec.height
      current[#current + 1] = entry
      kept[entry] = true
    end
  end

  -- Remove obsolete images before drawing their replacements at the same line.
  for _, entry in ipairs(previous) do
    if not kept[entry] then
      remove_entry(buffer, entry)
    end
  end
  image_cache[buffer] = current

  for _, entry in ipairs(current) do
    local row = vim.api.nvim_buf_get_extmark_by_id(buffer, anchors, entry.anchor, {})[1]
    local readable = vim.fn.filereadable(entry.path) == 1
    for window, image in pairs(entry.images) do
      if not visible[window] or not readable then
        dispose(image)
        entry.images[window] = nil
      end
    end
    if readable then
      for _, window in ipairs(windows) do
        local image = entry.images[window]
        if not image then
          local ok, created = pcall(api.from_file, entry.path, {
            id = ("%s:%d:%d:%d"):format(namespace, buffer, entry.id, window),
            window = window,
            buffer = buffer,
            inline = true,
            with_virtual_padding = true,
            width = entry.width,
            height = entry.height,
            x = 0,
            y = row,
            namespace = namespace,
          })
          if ok and created then
            entry.images[window] = created
            created:render()
          end
        elseif image.geometry.width ~= entry.width or image.geometry.height ~= entry.height then
          image:clear()
          -- Assign directly: render({ width = nil }) cannot reset an existing width.
          image.geometry.width, image.geometry.height = entry.width, entry.height
          image.geometry.y = row
          image:render()
        elseif image.geometry.y ~= row then
          -- Usually image.nvim's own extmark handler has already moved this image.
          image:move(0, row)
        end
      end
    end
  end
end

local function schedule_render(buffer, delay)
  local ticket = {}
  pending[buffer] = ticket
  vim.defer_fn(function()
    if pending[buffer] ~= ticket then
      return
    end
    pending[buffer] = nil
    if vim.api.nvim_buf_is_valid(buffer) then
      M.render(buffer)
    end
  end, delay)
end

function M.setup()
  local group = vim.api.nvim_create_augroup(namespace, { clear = true })
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = group,
    pattern = "*.py",
    callback = function(args)
      schedule_render(args.buf, 120)
    end,
  })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "BufWinLeave", "BufWritePost", "BufFilePost" }, {
    group = group,
    pattern = "*.py",
    callback = function(args)
      schedule_render(args.buf, 0)
    end,
  })
  -- image.nvim already handles WinScrolled, resizing, and movement of its padding extmarks.
  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function(args)
      local window = tonumber(args.match)
      for _, entries in pairs(image_cache) do
        for _, entry in ipairs(entries) do
          if entry.images[window] then
            dispose(entry.images[window])
            entry.images[window] = nil
          end
        end
      end
    end,
  })
  vim.api.nvim_create_autocmd({ "BufUnload", "BufDelete", "BufWipeout" }, {
    group = group,
    callback = function(args)
      clear(args.buf)
    end,
  })

  local buffer = vim.api.nvim_get_current_buf()
  if vim.api.nvim_buf_get_name(buffer):match "%.py$" then
    schedule_render(buffer, 0)
  end
end

return M
