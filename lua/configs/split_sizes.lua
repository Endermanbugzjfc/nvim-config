local M = {}

function M.setup()
  local sizes = {}
  local previous
  local rearrangement
  local last_arrangement
  local restoring = false

  local function snapshot()
    local windows = {}
    local layout = vim.fn.winlayout()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_get_config(win).relative == '' then
        windows[win] = {
          height = vim.api.nvim_win_get_height(win),
          width = vim.api.nvim_win_get_width(win),
          constrained = {},
        }
      end
    end
    local function visit(node, constrained)
      if node[1] == 'leaf' then
        if windows[node[2]] then windows[node[2]].constrained = constrained end
        return
      end
      local dimensions = vim.tbl_extend('force', constrained, {
        [node[1] == 'row' and 'width' or 'height'] = true,
      })
      for _, child in ipairs(node[2]) do visit(child, dimensions) end
    end
    visit(layout, {})
    return {
      windows = windows,
      layout = layout,
      columns = vim.o.columns,
      lines = vim.o.lines,
      tab = vim.api.nvim_get_current_tabpage(),
      active = vim.api.nvim_get_current_win(),
      restore_sizes = vim.fn.winrestcmd(),
    }
  end

  local group = vim.api.nvim_create_augroup('RememberSplitSizes', { clear = true })
  previous = snapshot()
  vim.api.nvim_create_autocmd('TabEnter', {
    group = group,
    callback = function() previous = snapshot() end,
  })
  local function resized()
    if restoring then return end
    if rearrangement then previous = rearrangement end
    local current = snapshot()
    local win = vim.api.nvim_get_current_win()
    local before, after = previous.windows[win], current.windows[win]
    local same_screen = previous.columns == current.columns and previous.lines == current.lines
    local same_layout = vim.deep_equal(previous.layout, current.layout)
    local same_windows = true
    for id in pairs(previous.windows) do
      if not current.windows[id] then same_windows = false end
    end
    for id in pairs(current.windows) do
      if not previous.windows[id] then same_windows = false end
    end
    if same_screen and same_windows and (rearrangement or not same_layout) then
      if not same_layout then last_arrangement = previous end
      -- Window IDs follow their panes through moves, exchanges and rotations.
      -- Restore peers first so the active pane has priority if space is tight.
      local order = vim.tbl_keys(current.windows)
      table.sort(order, function(a, b)
        if a == win then return false end
        if b == win then return true end
        return a < b
      end)
      for _, id in ipairs(order) do
        local old, new = previous.windows[id], current.windows[id]
        if vim.bo[vim.api.nvim_win_get_buf(id)].buftype == '' then
          for _, dimension in ipairs({ 'height', 'width' }) do
            if new.constrained[dimension] then
              local size = old.constrained[dimension] and old[dimension]
                or (id == win and sizes[dimension])
              if size then
                if dimension == 'height' then
                  vim.api.nvim_win_set_height(id, size)
                else
                  vim.api.nvim_win_set_width(id, size)
                end
              end
            end
          end
        end
      end
      current = snapshot()
    end
    -- Splitting, closing windows, and terminal resizes are not user size choices.
    if before and after and vim.bo.buftype == ''
      and same_screen and same_layout and not rearrangement then
      for _, dimension in ipairs({ 'height', 'width' }) do
        if before[dimension] ~= after[dimension] then
          sizes[dimension] = after[dimension]
        end
      end
    end
    previous = current
    rearrangement = nil
  end
  vim.api.nvim_create_autocmd('WinResized', {
    group = group,
    callback = resized,
  })

  local function before_rearrangement()
    local saved = snapshot()
    rearrangement = saved
    -- Also handle moves that keep the same ordering, or produce no resize event.
    vim.schedule(function()
      if rearrangement == saved then resized() end
    end)
  end

  local function restore_layout(layout)
    local function first_leaf(node)
      if node[1] == 'leaf' then return node[2] end
      return first_leaf(node[2][1])
    end
    local leaves = {}
    local function collect(node)
      if node[1] == 'leaf' then
        table.insert(leaves, node[2])
      else
        for _, child in ipairs(node[2]) do collect(child) end
      end
    end
    collect(layout)
    -- Start with a flat row, then rebuild each saved row/column using existing IDs.
    for _, win in ipairs(leaves) do
      vim.api.nvim_set_current_win(win)
      vim.cmd('noautocmd wincmd L')
    end
    local function build(node)
      if node[1] == 'leaf' then return end
      for index = 2, #node[2] do
        local result = vim.fn.win_splitmove(first_leaf(node[2][index]), first_leaf(node[2][index - 1]), {
          vertical = node[1] == 'row',
          rightbelow = true,
        })
        assert(result == 0, 'Could not restore pane arrangement')
      end
      for _, child in ipairs(node[2]) do build(child) end
    end
    build(layout)
  end

  vim.api.nvim_create_user_command('UndoPaneArrangement', function()
    -- Finish a command-line move if its scheduled size restoration is pending.
    if rearrangement then resized() end
    local saved = last_arrangement
    if not saved or not vim.api.nvim_tabpage_is_valid(saved.tab) then
      vim.notify('No pane arrangement to undo', vim.log.levels.INFO)
      return
    end
    local windows = {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(saved.tab)) do
      if vim.api.nvim_win_get_config(win).relative == '' then windows[win] = true end
    end
    local same_windows = vim.tbl_count(windows) == vim.tbl_count(saved.windows)
    for win in pairs(saved.windows) do
      if not windows[win] then same_windows = false end
    end
    if not same_windows then
      vim.notify('Cannot undo pane arrangement after panes were opened or closed', vim.log.levels.WARN)
      return
    end
    restoring = true
    local ok, err = pcall(function()
      vim.api.nvim_set_current_tabpage(saved.tab)
      restore_layout(saved.layout)
      vim.api.nvim_set_current_win(saved.active)
      -- Resizing an outer frame can disturb inner frames restored earlier.
      for _ = 1, vim.tbl_count(saved.windows) do
        vim.cmd(saved.restore_sizes)
        local matched = true
        for win, size in pairs(saved.windows) do
          if vim.api.nvim_win_get_height(win) ~= size.height
            or vim.api.nvim_win_get_width(win) ~= size.width then matched = false end
        end
        if matched then break end
      end
    end)
    restoring = false
    previous = snapshot()
    if ok then
      last_arrangement = nil
    else
      vim.notify('Could not undo pane arrangement: ' .. tostring(err), vim.log.levels.ERROR)
    end
  end, { desc = 'Undo the last pane rearrangement (one level)' })

  for _, direction in ipairs({ 'H', 'J', 'K', 'L', 'r', 'R', 'x' }) do
    vim.keymap.set('n', '<C-w>' .. direction, function()
      local count = vim.v.count > 0 and tostring(vim.v.count) or ''
      before_rearrangement()
      vim.cmd(count .. 'wincmd ' .. direction)
      resized()
    end, { desc = 'Rearrange panes preserving sizes (' .. direction .. ')' })
  end

  vim.api.nvim_create_autocmd('CmdlineLeave', {
    group = group,
    pattern = ':',
    callback = function()
      if vim.v.event.abort then return end
      local line = vim.fn.getcmdline()
      local ok, cmd = pcall(vim.api.nvim_parse_cmd, line, {})
      if not ok then return end
      if cmd.cmd == 'wincmd' and #cmd.args == 1 and cmd.args[1]:match('^[HJKLrRx]$') then
        before_rearrangement()
        return
      end
      if cmd.cmd ~= 'split' and cmd.cmd ~= 'vsplit' then return end
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
