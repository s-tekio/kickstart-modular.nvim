local closed_buffers = {}

-- Each time a buffer is closed, save it in the list
vim.api.nvim_create_autocmd('BufDelete', {
  callback = function(args)
    local buf_name = vim.api.nvim_buf_get_name(args.buf)
    if buf_name ~= '' and vim.bo[args.buf].buftype == '' then table.insert(closed_buffers, buf_name) end
  end,
})

local function smart_quit()
  -- 1. If the cursor is in Neo-tree, just close it
  if vim.bo.filetype == 'neo-tree' then
    vim.cmd 'Neotree close'
    return
  end

  -- 2. Detect how many real windows there are
  local wins = vim.api.nvim_tabpage_list_wins(0)
  local real_wins = {}
  for _, win in ipairs(wins) do
    local cfg = vim.api.nvim_win_get_config(win)
    if cfg.relative == '' then table.insert(real_wins, win) end
  end

  -- 3. Check if Neo-tree is open (using its API)
  local nt_manager = require 'neo-tree.sources.manager'
  local nt_open = false
  -- Check the "filesystem" source which is the standard one
  local state = nt_manager.get_state 'filesystem'
  if state and state.winid and vim.api.nvim_win_is_valid(state.winid) then nt_open = true end

  -- Calculate "content" windows (not counting Neo-tree)
  local content_wins_count = nt_open and (#real_wins - 1) or #real_wins

  -- 4. WINDOW RULE
  -- If after removing Neo-tree you still have more than 1 window (real splits)
  if content_wins_count > 1 then
    vim.cmd 'close'
    return
  end

  -- 5. BUFFER RULE (When only 1 content window remains)
  local buffers = vim.fn.getbufinfo { buflisted = 1 }

  if #buffers <= 1 then
    -- Last buffer: close everything (including Neo-tree if it was open)
    vim.cmd 'qa'
  else
    -- More buffers exist: close only the current buffer without breaking the split
    Snacks.bufdelete()
  end
end

return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    require('bufferline').setup {
      options = {
        mode = 'buffers', -- Use 'tabs' if you prefer real nvim tabs
        style_preset = require('bufferline').style_preset.default,

        indicator = { style = 'icon', icon = '▎' },
        -- indicator = { style = 'underline' },
        separator_style = 'thin', -- 'slant' | 'slope' | 'thick' | 'thin'

        buffer_close_icon = '󰅖',
        modified_icon = '●',
        close_icon = '',
        left_trunc_marker = '',
        right_trunc_marker = '',

        -- NEO-TREE INTEGRATION
        -- Makes the buffer bar start after the file tree
        offsets = {
          {
            filetype = 'neo-tree',
            text = 'File Explorer',
            text_align = 'center',
            separator = true,
          },
        },

        -- Diagnostics (LSP) directly on the tab
        diagnostics = 'nvim_lsp',
        diagnostics_indicator = function(count, level)
          local icon = level:match 'error' and ' ' or ' '
          return '(' .. icon .. count .. ')'
        end,

        -- Behavior
        groups = { items = {} },
        show_buffer_close_icons = true,
        show_close_icon = true,
        persist_buffer_sort = true,
      },
      highlights = {
        indicator_selected = {
          fg = '#ff9e64',
          sp = '#ff9e64',
          -- underline = true,
          bold = true,
        },
        buffer_selected = {
          bold = true,
          italic = false,
        },
      },
    }

    -- KEYMAPS
    local map = vim.keymap.set
    -- Quick navigation (Shift + L/H)
    map('n', '<S-l>', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next Buffer' })
    map('n', '<S-h>', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Prev Buffer' })

    -- Move buffers position (Alt + L/H)
    map('n', '<A-l>', '<cmd>BufferLineMoveNext<cr>', { desc = 'Move Buffer Right' })
    map('n', '<A-h>', '<cmd>BufferLineMovePrev<cr>', { desc = 'Move Buffer Left' })

    -- "Pick" (Direct jump with a key)
    map('n', '<leader>bk', '<cmd>BufferLinePick<cr>', { desc = 'Buffer Pick' })
    -- "Pin"
    map('n', '<leader>bp', '<cmd>BufferLineTogglePin<cr>', { desc = 'Buffer Toggle Pin' })

    -- Close buffers (using snacks to avoid breaking the layout if possible)
    map('n', '<leader>bd', function() Snacks.bufdelete() end, { desc = 'Delete Buffer' })
    map('n', '<leader>q', smart_quit, { desc = 'Smart Quit (Buffer or Neovim)' })
    map('n', '<leader>bl', '<cmd>BufferLineCloseLeft<cr>', { desc = 'Close Left Buffers' })
    map('n', '<leader>br', '<cmd>BufferLineCloseRight<cr>', { desc = 'Close Righ Buffers' })
    map('n', '<leader>bo', '<cmd>BufferLineCloseOthers<cr>', { desc = 'Close Other Buffers' })

    map('n', '<leader>bt', function()
      if #closed_buffers > 0 then
        local last_buf = table.remove(closed_buffers)
        vim.cmd('edit ' .. last_buf)
      else
        vim.notify('No more buffers to restore', vim.log.levels.INFO)
      end
    end, { desc = '[B]uffer [T]ab Restore' })
  end,
}
