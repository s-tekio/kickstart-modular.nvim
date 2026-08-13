return {
  'kevinhwang91/nvim-ufo',
  dependencies = 'kevinhwang91/promise-async',
  event = 'BufReadPost',
  init = function()
    vim.o.foldcolumn = '0'
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true
  end,
  config = function()
    local ufo = require 'ufo'

    ufo.setup {
      provider_selector = function(bufnr, filetype, buftype) return { 'lsp', 'indent' } end,
    }

    vim.keymap.set('n', 'zo', '<cmd>foldopen<CR>', { desc = 'Open fold under cursor (ufo)' })
    vim.keymap.set('n', 'zc', '<cmd>foldclose<CR>', { desc = 'Close fold under cursor (ufo)' })

    vim.keymap.set('n', 'zR', ufo.openAllFolds, { desc = 'Open all folds (ufo)' })
    vim.keymap.set('n', 'zM', ufo.closeAllFolds, { desc = 'Close all folds (ufo)' })

    -- Peek fold o LSP Hover:
    vim.keymap.set('n', 'K', function()
      local winid = ufo.peekFoldedLinesUnderCursor()
      if not winid then vim.lsp.buf.hover() end
    end, { desc = 'Peek fold (ufo) or Hover LSP' })
  end,
}
