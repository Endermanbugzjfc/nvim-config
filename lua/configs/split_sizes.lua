local M = {}

function M.setup()
  local sizes = {}
  local previous

  local function snapshot()
    local windows = {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_get_config(win).relative == '' then
        windows[win] = {
          height = vim.api.nvim_win_get_height(win),
          width = vim.api.nvim_win_get_width(win),
        }
      end
    end
    return {
      windows = windows,
      layout = vim.fn.winlayout(),
      columns = vim.o.columns,
      lines = vim.o.lines,
    }
  end

  local group = vim.api.nvim_create_augroup('RememberSplitSizes', { clear = true })
  previous = snapshot()
  vim.api.nvim_create_autocmd('TabEnter', {
    group = group,
    callback = function() previous = snapshot() end,
  })
  vim.api.nvim_create_autocmd('WinResized', {
    group = group,
    callback = function()
      local current = snapshot()
      local win = vim.api.nvim_get_current_win()
      local before, after = previous.windows[win], current.windows[win]
      -- Splitting, closing windows, and terminal resizes are not user size choices.
      if before and after and vim.bo.buftype == ''
        and previous.columns == current.columns and previous.lines == current.lines
        and vim.deep_equal(previous.layout, current.layout) then
        for _, dimension in ipairs({ 'height', 'width' }) do
          if before[dimension] ~= after[dimension] then
            sizes[dimension] = after[dimension]
          end
        end
      end
      previous = current
    end,
  })

  vim.api.nvim_create_autocmd('CmdlineLeave', {
    group = group,
    pattern = ':',
    callback = function()
      if vim.v.event.abort then return end
      local line = vim.fn.getcmdline()
      local ok, cmd = pcall(vim.api.nvim_parse_cmd, line, {})
      if not ok or (cmd.cmd ~= 'split' and cmd.cmd ~= 'vsplit') then return end
      -- Keep explicit sizes and tab commands under native command control.
      if cmd.count or (cmd.range and #cmd.range > 0) or cmd.mods.tab >= 0 then return end
      local vertical = cmd.cmd == 'vsplit' or cmd.mods.vertical
      local size = sizes[vertical and 'width' or 'height']
      if not size then return end
      -- Insert a native count, preserving modifiers, file arguments and +commands.
      for start, word in line:gmatch('()(%a+)') do
        if #word >= 2 and cmd.cmd:sub(1, #word) == word then
          vim.fn.setcmdline(line:sub(1, start - 1) .. size .. line:sub(start))
          return
        end
      end
    end,
  })
end

return M
