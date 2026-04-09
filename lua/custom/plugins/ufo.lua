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
    require('ufo').setup()

    vim.keymap.set('n', '<A-->', '<cmd>foldclose<CR>', { desc = 'Close fold' })
    vim.keymap.set('n', '<A-+>', '<cmd>foldopen<CR>', { desc = 'Open fold' })

    -- vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = 'Close all folds' })
    -- vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = 'Open all folds' })
  end,
}
