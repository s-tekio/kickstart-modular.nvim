-- Alternatively, use `config = function() ... end` for full control over the configuration.
-- If you prefer to call `setup` explicitly, use:
--    {
--        'lewis6991/gitsigns.nvim',
--        config = function()
--            require('gitsigns').setup({
--                -- Your gitsigns configuration here
--            })
--        end,
--    }
--
-- Here is a more advanced example where we pass configuration
-- options to `gitsigns.nvim`.
--
-- See `:help gitsigns` to understand what the configuration keys do

---@module 'lazy'
---@type LazySpec
return {
  'lewis6991/gitsigns.nvim',
  ---@module 'gitsigns'
  ---@type Gitsigns.Config
  ---@diagnostic disable-next-line: missing-fields
  opts = {
    signs = {
      add = { text = '▎' }, ---@diagnostic disable-line: missing-fields
      change = { text = '▎' }, ---@diagnostic disable-line: missing-fields
      delete = { text = '' }, ---@diagnostic disable-line: missing-fields
      topdelete = { text = '' }, ---@diagnostic disable-line: missing-fields
      changedelete = { text = '▎' }, ---@diagnostic disable-line: missing-fields
      untracked = { text = '▎' }, ---@diagnostic disable-line: missing-fields
    },
    signs_staged = {
      add = { text = '▎' }, ---@diagnostic disable-line: missing-fields
      change = { text = '▎' }, ---@diagnostic disable-line: missing-fields
      delete = { text = '' }, ---@diagnostic disable-line: missing-fields
      topdelete = { text = '' }, ---@diagnostic disable-line: missing-fields
      changedelete = { text = '▎' }, ---@diagnostic disable-line: missing-fields
      untracked = { text = '▎' }, ---@diagnostic disable-line: missing-fields
    },
    signs_staged_enable = true,
    -- signs = {
    --   add = { text = '+' }, ---@diagnostic disable-line: missing-fields
    --   change = { text = '~' }, ---@diagnostic disable-line: missing-fields
    --   delete = { text = '_' }, ---@diagnostic disable-line: missing-fields
    --   topdelete = { text = '‾' }, ---@diagnostic disable-line: missing-fields
    --   changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
    -- },
    on_attach = function(bufnr)
      local gitsigns = require 'gitsigns'

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation
      map('n', ']c', function()
        if vim.wo.diff then
          vim.cmd.normal { ']c', bang = true }
        else
          gitsigns.nav_hunk 'next'
        end
      end, { desc = 'Jump to next git [c]hange' })

      map('n', '[c', function()
        if vim.wo.diff then
          vim.cmd.normal { '[c', bang = true }
        else
          gitsigns.nav_hunk 'prev'
        end
      end, { desc = 'Jump to previous git [c]hange' })

      -- Actions
      -- visual mode
      map('v', '<leader>ghs', function() gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'Git: [s]tage hunk' })
      map('v', '<leader>ghr', function() gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'Git: [r]eset hunk' })
      -- normal mode
      map('n', '<leader>ghs', gitsigns.stage_hunk, { desc = 'Git: [s]tage hunk' })
      map('n', '<leader>ghr', gitsigns.reset_hunk, { desc = 'Git: [r]eset hunk' })
      map('n', '<leader>ghS', gitsigns.stage_buffer, { desc = 'Git: [S]tage buffer' })
      map('n', '<leader>ghu', gitsigns.stage_hunk, { desc = 'Git: [u]ndo stage hunk' })
      map('n', '<leader>ghR', gitsigns.reset_buffer, { desc = 'Git: [R]eset buffer' })
      map('n', '<leader>ghp', gitsigns.preview_hunk, { desc = 'Git: [p]review hunk' })
      map('n', '<leader>ghb', gitsigns.blame_line, { desc = 'Git: [b]lame line' })
      map('n', '<leader>ghB', gitsigns.blame, { desc = 'Git: [B]lame buffer' })
      map('n', '<leader>ghd', gitsigns.diffthis, { desc = 'Git: [d]iff against index' })
      map('n', '<leader>ghD', function() gitsigns.diffthis '@' end, { desc = 'Git: [D]iff against last commit' })
      -- Toggles
      map('n', '<leader>gtb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
      map('n', '<leader>gtw', gitsigns.toggle_word_diff, { desc = '[T]oggle git show [w]ord diff' })
      map('n', '<leader>gtD', gitsigns.preview_hunk_inline, { desc = '[T]oggle git show [D]eleted' })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
