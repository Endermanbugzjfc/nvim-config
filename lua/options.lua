require "nvchad.options"

vim.o.clipboard = ""
vim.o.mouse = ""
vim.o.foldmethod = "marker"
vim.g.lua_snippets_path = vim.fn.stdpath "config" .. "/lua/lua_snippets"


-- https://tech.serhatteker.com/post/2020-06/close-all-buffers-but-current-in-vim/
-- vim.cmd("command! Bonly :normal! mx :%bdelete|edit#|bdelete#<CR>")

-- Automatically `cd` to last argument:
vim.o.autochdir = true
vim.schedule(function()
  vim.o.autochdir = false
end)

-- Async write for laggy environment like SSHFS:
vim.api.nvim_create_user_command('A', function()
  local filepath = vim.api.nvim_buf_get_name(0)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, '\n') .. '\n'

  vim.bo.modified = false  -- optimistically mark clean

  local job_id = vim.fn.jobstart({'tee', filepath}, {
    on_exit = function(_, code)
      if code ~= 0 then
        vim.schedule(function()
          vim.notify('Write failed: ' .. filepath, vim.log.levels.ERROR)
          vim.bo.modified = true
        end)
      end
    end,
  })

  vim.fn.chansend(job_id, content)
  vim.fn.chanclose(job_id, 'stdin')
end, {})
