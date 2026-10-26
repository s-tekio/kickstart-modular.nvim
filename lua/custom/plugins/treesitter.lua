---@module 'lazy'
---@type LazySpec
return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    branch = 'main',
    config = function()
      -- The `main` branch installs parsers into stdpath('data')/site (the default) and has no
      -- `setup()` options for highlight/indent: highlighting and indentation are wired here.
      local parsers = {
        'bash',
        'c',
        'css',
        'diff',
        'html',
        'javascript',
        'json',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'php',
        'php_only',
        'query',
        'scss',
        'terraform',
        'tsx',
        'twig',
        'typescript',
        'vim',
        'vimdoc',
        'yaml',
      }

      require('nvim-treesitter').install(parsers)

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local buf, filetype = args.buf, args.match

          local language = vim.treesitter.language.get_lang(filetype)
          if not language then return end

          -- Load the parser when it exists; files without one keep their regex syntax.
          if not vim.treesitter.language.add(language) then return end

          -- Syntax highlighting and other treesitter features.
          vim.treesitter.start(buf, language)

          -- Treesitter based indentation (see `:help treesitter-indent`).
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
