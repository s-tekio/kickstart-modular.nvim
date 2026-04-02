local function smart_quit()
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })

  if #buffers <= 1 then
    vim.cmd('qa')
  else
    vim.cmd('bdelete')
    -- Snacks.bufdelete()
  end
end

return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    require("bufferline").setup({
      options = {
        mode = "buffers", -- Usa 'tabs' si prefieres pestañas reales de nvim
        style_preset = require("bufferline").style_preset.default,

        -- Iconos y estética
        indicator = { style = 'icon', icon = '▎' },
        buffer_close_icon = '󰅖',
        modified_icon = '●',
        close_icon = '',
        left_trunc_marker = '',
        right_trunc_marker = '',

        -- INTEGRACIÓN CON NEO-TREE
        -- Esto hace que la barra de buffers empiece después del árbol
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            text_align = "center",
            separator = true,
          }
        },

        -- Diagnósticos (LSP) directamente en la pestaña
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(count, level)
          local icon = level:match("error") and " " or " "
          return "(" .. icon .. count .. ")"
        end,

        -- Comportamiento
        groups = { items = {} },
        separator_style = "thin", -- 'slant' | 'slope' | 'thick' | 'thin'
        show_buffer_close_icons = true,
        show_close_icon = true,
        persist_buffer_sort = true,
      }
    })

    -- KEYMAPS
    local map = vim.keymap.set
    -- Navegación rápida (Shift + L/H)
    map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next Buffer" })
    map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev Buffer" })

    -- Mover buffers de posición (Alt + L/H)
    map("n", "<A-l>", "<cmd>BufferLineMoveNext<cr>", { desc = "Move Buffer Right" })
    map("n", "<A-h>", "<cmd>BufferLineMovePrev<cr>", { desc = "Move Buffer Left" })

    -- "Pick" (Salto directo con una tecla)
    map("n", "<leader>bp", "<cmd>BufferLinePick<cr>", { desc = "Buffer Pick" })

    -- Cerrar buffers (usando snacks para no romper el layout si es posible)
    map("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = "Delete Buffer" })
    map("n", "<leader>q", smart_quit, { desc = "Smart Quit (Buffer or Neovim)" })
    map("n", "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", { desc = "Close Other Buffers" })
  end
}
