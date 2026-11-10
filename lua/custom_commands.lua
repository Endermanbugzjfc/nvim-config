-- This file contains custom commands. Note: Neovim requires custom commands to have a capitalised
-- first letter.

-- These have been extracted from options.lua as they weren't supposed to be there, but I didn't
-- want to touch code when they work fine:

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

-- Vimgrep current file type:
vim.api.nvim_create_user_command("V", function(opts)
  local pattern = opts.args
  local ext = vim.fn.expand("%:e")

  if ext == "" then
    vim.notify("No file extension detected", vim.log.levels.WARN)
    return
  end

  vim.cmd(string.format("vimgrep /%s/ **/*.%s", pattern, ext))
  vim.cmd("copen")
end, {
  nargs = 1,
  desc = "Vimgrep pattern across current filetype",
})

vim.api.nvim_create_user_command("Img", ":Lazy load image.nvim", {})
