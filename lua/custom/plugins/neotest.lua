return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'olimorris/neotest-phpunit',
    },
    config = function()
      --- @diagnostic disable-next-line: missing-fields
      require('neotest').setup {
        adapters = {
          require 'neotest-phpunit' {
            phpunit_cmd = function() return 'vendor/bin/phpunit' end,
          },
        },
      }

      local map = vim.keymap.set
      map('n', '<leader>tt', function() require('neotest').run.run() end, { desc = '[T]est [R]un nearest' })
      map('n', '<leader>tf', function() require('neotest').run.run(vim.fn.expand '%') end, { desc = '[T]est run [F]ile' })
      map('n', '<leader>ts', function() require('neotest').summary.toggle() end, { desc = '[T]est [S]ummary toggle' })
      map('n', '<leader>to', function() require('neotest').output_panel.toggle() end, { desc = '[T]est [O]utput panel' })
      map('n', '[t', function() require('neotest').jump.prev { status = 'failed' } end, { desc = 'Jump to previous failed test' })
      map('n', ']t', function() require('neotest').jump.next { status = 'failed' } end, { desc = 'Jump to next failed test' })
    end,
  },
}
