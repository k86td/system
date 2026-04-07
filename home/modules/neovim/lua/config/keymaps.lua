-- Custom keymaps configuration

-- allows to exit TERMINAL mode inside toggleterm with Esc (but not lazygit or claudecode)
vim.keymap.set('t', '<Esc>', function()
  if vim.bo.filetype == 'lazygit' then
    return '<Esc>'
  else
    return [[<C-\><C-n>]]
  end
end, { noremap = true, silent = true, expr = true })

-- Movement
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Aller à la fenêtre de gauche' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Aller à la fenêtre du bas' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Aller à la fenêtre du haut' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Aller à la fenêtre de droite' })

vim.keymap.set('n', '<C-Up>', '<cmd>resize +2<CR>', { desc = 'Augmenter la hauteur' })
vim.keymap.set('n', '<C-Down>', '<cmd>resize -2<CR>', { desc = 'Diminuer la hauteur' })
vim.keymap.set('n', '<C-Left>', '<cmd>vertical resize -2<CR>', { desc = 'Diminuer la largeur' })
vim.keymap.set('n', '<C-Right>', '<cmd>vertical resize +2<CR>', { desc = 'Augmenter la largeur' })

-- Search
vim.keymap.set('n', '<leader>fs', function()
  require('telescope.builtin').lsp_dynamic_workspace_symbols()
end, { desc = 'Chercher des symboles dans le projet' })
vim.keymap.set('n', '<leader>fw', function()
  require('telescope.builtin').grep_string()
end, { desc = 'Chercher le mot sous le curseur' })
