-- Diagnostic configuration
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",  -- You can use "", "●", "■", "▶", etc.
    spacing = 4,   -- Space between code and the message
  },
  signs = true,     -- Keeps the sign column indicators
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
