-- Custom keymaps configuration

-- allows to exit TERMINAL mode inside toggleterm with Esc (but not lazygit or claudecode)
vim.keymap.set('t', '<Esc>', function()
  if vim.bo.filetype == 'lazygit' then
    return '<Esc>'
  else
    return [[<C-\><C-n>]]
  end
end, { noremap = true, silent = true, expr = true })
