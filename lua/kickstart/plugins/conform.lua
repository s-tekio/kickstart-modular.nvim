---@module 'lazy'
---@type LazySpec
return {
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>F',
        function() require('conform').format { async = true, lsp_format = 'fallback' } end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    ---@module 'conform'
    ---@diagnostic disable-next-line: undefined-doc-name
    ---@type conform.setupOpts
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- [[ New Toggle Logic ]]
        -- If global autoformat is disabled OR buffer autoformat is disabled, return nil
        if vim.g.autoformat == false or vim.b[bufnr].autoformat == false then return nil end

        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style.
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then return nil end

        return {
          timeout_ms = 1000,
          lsp_format = 'fallback',
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        php = { 'php_cs_fixer' },
      },
      formatters = {
        php_cs_fixer = {
          command = 'php-cs-fixer',
          args = {
            'fix',
            '$FILENAME',
            '--allow-risky=yes',
            '--quiet',
            function()
              local config = vim.fs.find({ '.php-cs-fixer.dist.php', '.php-cs-fixer.php' }, { upward = true })[1]
              if config then return '--config=' .. config end
              return nil -- Si no hay config, devolvemos nil y conform lo ignora
            end,
          },
          stdin = false,
        },
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
