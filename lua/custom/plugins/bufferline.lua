local function smart_quit()
  -- 1. Si el cursor está en Neo-tree, simplemente lo cerramos
  if vim.bo.filetype == 'neo-tree' then
    vim.cmd 'Neotree close'
    return
  end

  -- 2. Detectamos cuántas ventanas reales hay
  local wins = vim.api.nvim_tabpage_list_wins(0)
  local real_wins = {}
  for _, win in ipairs(wins) do
    local cfg = vim.api.nvim_win_get_config(win)
    if cfg.relative == '' then table.insert(real_wins, win) end
  end

  -- 3. Comprobamos si Neo-tree está abierto (usando su API)
  local nt_manager = require 'neo-tree.sources.manager'
  local nt_open = false
  -- Comprobamos la fuente "filesystem" que es la estándar
  local state = nt_manager.get_state 'filesystem'
  if state and state.winid and vim.api.nvim_win_is_valid(state.winid) then nt_open = true end

  -- Calculamos las ventanas "de contenido" (sin contar Neo-tree)
  local content_wins_count = nt_open and (#real_wins - 1) or #real_wins

  -- 4. REGLA DE VENTANAS
  -- Si después de quitar Neo-tree, sigues teniendo más de 1 ventana (splits reales)
  if content_wins_count > 1 then
    vim.cmd 'close'
    return
  end

  -- 5. REGLA DE BUFFERS (Cuando solo queda 1 ventana de contenido)
  local buffers = vim.fn.getbufinfo { buflisted = 1 }

  if #buffers <= 1 then
    -- Es el último buffer: cerramos todo (incluyendo Neo-tree si estaba abierto)
    vim.cmd 'qa'
  else
    -- Hay más pestañas: cerramos solo el buffer actual sin romper el split
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
        mode = 'buffers', -- Usa 'tabs' si prefieres pestañas reales de nvim
        style_preset = require('bufferline').style_preset.default,

        indicator = { style = 'icon', icon = '▎' },
        -- indicator = { style = 'underline' },
        separator_style = 'thin', -- 'slant' | 'slope' | 'thick' | 'thin'

        buffer_close_icon = '󰅖',
        modified_icon = '●',
        close_icon = '',
        left_trunc_marker = '',
        right_trunc_marker = '',

        -- INTEGRACIÓN CON NEO-TREE
        -- Esto hace que la barra de buffers empiece después del árbol
        offsets = {
          {
            filetype = 'neo-tree',
            text = 'File Explorer',
            text_align = 'center',
            separator = true,
          },
        },

        -- Diagnósticos (LSP) directamente en la pestaña
        diagnostics = 'nvim_lsp',
        diagnostics_indicator = function(count, level)
          local icon = level:match 'error' and ' ' or ' '
          return '(' .. icon .. count .. ')'
        end,

        -- Comportamiento
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
    -- Navegación rápida (Shift + L/H)
    map('n', '<S-l>', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next Buffer' })
    map('n', '<S-h>', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Prev Buffer' })

    -- Mover buffers de posición (Alt + L/H)
    map('n', '<A-l>', '<cmd>BufferLineMoveNext<cr>', { desc = 'Move Buffer Right' })
    map('n', '<A-h>', '<cmd>BufferLineMovePrev<cr>', { desc = 'Move Buffer Left' })

    -- "Pick" (Salto directo con una tecla)
    map('n', '<leader>bp', '<cmd>BufferLinePick<cr>', { desc = 'Buffer Pick' })

    -- Cerrar buffers (usando snacks para no romper el layout si es posible)
    map('n', '<leader>bd', function() Snacks.bufdelete() end, { desc = 'Delete Buffer' })
    map('n', '<leader>q', smart_quit, { desc = 'Smart Quit (Buffer or Neovim)' })
    map('n', '<leader>bo', '<cmd>BufferLineCloseOthers<cr>', { desc = 'Close Other Buffers' })
  end,
}
