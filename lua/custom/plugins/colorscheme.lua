---@module 'lazy'
---@type LazySpec
return {
  {
    'vague-theme/vague.nvim',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other plugins
    config = function()
      -- NOTE: you do not need to call setup if you don't want to.
      require('vague').setup {
        -- optional configuration here
      }
      -- vim.cmd 'colorscheme vague'
    end,
  },
  {
    'nickkadutskyi/jb.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      -- require('jb').setup { transparent = true }
      vim.cmd 'colorscheme jb'
    end,
  },
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    lazy = false,
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('tokyonight').setup {
        styles = {
          comments = { italic = false },
        },
      }
      -- vim.cmd.colorscheme 'tokyonight-night'
    end,
  },
  {
    'rose-pine/neovim',
    lazy = false,
    name = 'rose-pine',
    config = function()
      -- vim.cmd("colorscheme rose-pine")
    end,
  },
  {
    'webhooked/kanso.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      -- vim.cmd("colorscheme kanso")
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
