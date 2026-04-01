---@module 'lazy'
---@type LazySpec
return {
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
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
      format_on_save = false,
      -- format_on_save = function(bufnr)
      --   -- Disable "format_on_save lsp_fallback" for languages that don't
      --   -- have a well standardized coding style. You can add additional
      --   -- languages here or re-enable it for the disabled ones.
      --   local disable_filetypes = { c = true, cpp = true }
      --   if disable_filetypes[vim.bo[bufnr].filetype] then
      --     return nil
      --   else
      --     return {
      --       timeout_ms = 2000,
      --       lsp_format = 'fallback',
      --     }
      --   end
      -- end,
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
          },
          stdin = false,
        },
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
