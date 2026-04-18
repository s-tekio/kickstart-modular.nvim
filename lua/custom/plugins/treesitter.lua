---@module 'lazy'
---@type LazySpec
return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    branch = 'main',
    config = function()
      local ensure_installed = {
        'bash',
        -- 'c',
        'diff',
        'html',
        'css',
        'javascript',
        'typescript',
        'twig',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'php',
        'query',
        'vim',
        'vimdoc',
        'yaml',
      }

      require('nvim-treesitter').setup {
        install_dir = vim.fs.joinpath(vim.fn.stdpath 'data', 'site'),
        ensure_installed = ensure_installed,
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      }
    end,
  },
}
