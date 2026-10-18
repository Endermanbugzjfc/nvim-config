local M = {}

-- Lua's balanced-angle pattern also matches comparisons and stops at a quoted
-- `>`. Scan opening tags separately, leaving mini.splitjoin's defaults intact.
local function find_tag(text, offset)
  local start = 1
  while true do
    local left, name_end = text:find("<[%a][%w:._-]*", start)
    if not left or left > offset then return end
    local i, quote = name_end + 1, nil
    if text:sub(i, i):match("[%s/>]") then
      while i <= #text do
        local char = text:sub(i, i)
        if quote then
          if char == quote then quote = nil end
        elseif char == '"' or char == "'" then
          quote = char
        elseif char == "<" then
          break
        elseif char == ">" then
          if offset <= i then return left, name_end, i end
          break
        end
        i = i + 1
      end
    end
    start = math.max(i, name_end + 1)
  end
end

local function tag_options(splitjoin, opts)
  opts = opts or {}
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local text = table.concat(lines, "\n")
  local offsets, total = {}, 0
  for i, line in ipairs(lines) do
    offsets[i], total = total, total + #line + 1
  end
  local function to_offset(pos) return offsets[pos.line] + pos.col end
  local function to_position(offset)
    for i = #offsets, 1, -1 do
      if offset > offsets[i] then return { line = i, col = offset - offsets[i] } end
    end
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local position = opts.position or { line = cursor[1], col = cursor[2] + 1 }
  local offset = to_offset(opts.region and opts.region.from or position)
  local left, name_end, right = find_tag(text, offset)
  if not left then return opts end

  local config = vim.tbl_deep_extend("force", {}, splitjoin.config, vim.b.minisplitjoin_config or {}, opts)
  if opts.region then
    -- An explicit selection wins. Already-prepared tag options also take this
    -- path when toggle() delegates to split() or join().
    if to_offset(opts.region.from) ~= left or to_offset(opts.region.to) ~= right then return opts end
  else
    -- Keep the usual smallest enclosing bracket behavior inside attributes.
    local brackets = config.detect.brackets or { "%b()", "%b[]", "%b{}" }
    for _, pattern in ipairs(brackets) do
      local from, to = text:find(pattern)
      while from and from <= offset do
        if offset <= to and to - from <= right - left then return opts end
        from, to = text:find(pattern, from + 1)
      end
    end
  end

  local close = text:sub(right - 1, right - 1) == "/" and right - 1 or right
  if text:sub(name_end + 1, close - 1):match("^%s*$") then return opts end

  -- Only unquoted whitespace between attributes is a separator. Commas in
  -- unquoted values and whitespace around `=` belong to the attribute.
  local positions = { to_position(name_end) }
  local i, quote = name_end + 1, nil
  while i < close do
    local char = text:sub(i, i)
    if quote then
      if char == quote then quote = nil end
    elseif char == '"' or char == "'" then
      quote = char
    elseif char:match("%s") then
      local next_attr = text:find("%S", i) or close
      if
        i > name_end + 1
        and next_attr < close
        and text:sub(i - 1, i - 1) ~= "="
        and text:sub(next_attr, next_attr) ~= "="
      then
        table.insert(positions, to_position(i - 1))
      end
      i = next_attr - 1
    end
    i = i + 1
  end
  table.insert(positions, to_position(close - 1))

  opts = vim.deepcopy(opts)
  -- Treat the last byte of the tag name as the opening bracket, and keep `/>`
  -- together. This reuses mini.splitjoin's indent and cursor tracking.
  opts.region = { from = to_position(name_end), to = to_position(close) }
  opts.detect = vim.tbl_extend("force", opts.detect or {}, { separator = "" })
  opts.split = vim.deepcopy(config.split)
  table.insert(opts.split.hooks_pre, 1, function() return positions end)
  opts.join = vim.deepcopy(config.join)
  local first_newline = text:find("\n", name_end, true)
  local needs_join_pad = first_newline and first_newline < close
    and (text:find("%S", first_newline + 1) or close) < close
  table.insert(opts.join.hooks_post, 1, function(joined)
    -- mini.splitjoin removes padding at bracket edges. Keep a space at the
    -- first join boundary unless the following line only closes the tag.
    if not needs_join_pad then return joined end
    local first = joined[1]
    vim.api.nvim_buf_set_text(0, first.line - 1, first.col, first.line - 1, first.col, { " " })
    for j = 2, #joined do
      if joined[j].line == first.line then joined[j].col = joined[j].col + 1 end
    end
    return joined
  end)
  return opts
end

local original = {}
function M.setup()
  local splitjoin = require "mini.splitjoin"
  splitjoin.setup()
  -- Keep the built-in mappings/operator so Visual mode and dot-repeat continue
  -- to use the same context-sensitive options as direct API calls.
  for _, action in ipairs { "toggle", "split", "join" } do
    original[action] = original[action] or splitjoin[action]
    local run = original[action]
    splitjoin[action] = function(opts)
      if vim.g.minisplitjoin_disable == true or vim.b.minisplitjoin_disable == true then return run(opts) end
      return run(tag_options(splitjoin, opts))
    end
  end
end

return M
