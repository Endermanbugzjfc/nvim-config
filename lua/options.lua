require "nvchad.options"

vim.o.clipboard = ""

-- https://tech.serhatteker.com/post/2020-06/close-all-buffers-but-current-in-vim/
vim.cmd("command! Bonly :normal! mx :%bdelete|edit#|bdelete#<CR>")
