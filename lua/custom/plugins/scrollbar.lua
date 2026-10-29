return {
  'petertriho/nvim-scrollbar',
  -- v2 lands on main on 2026-11-16; remove this line after that date
  branch = 'refactor/v2',
  -- `keys` would make lazy.nvim defer loading until the first keypress
  lazy = false,
  keys = {
    { '<leader>us', '<cmd>MinimapToggle<cr>', desc = 'Toggle minimap' },
  },
  opts = {
    providers = {
      gitsigns = true, -- Requires gitsigns
    },
    scrollbar = {
      unit = 'screenline', -- account for closed folds and wrapped lines
      autohide = true, -- reveal on cursor/scroll activity, hide 1s after it stops
      -- kanso-ink palette (kanso/colors.lua): inkBg1 #1f1f26, inkBg4 #4b4e57
      track = { highlight = { bg = '#1f1f26' } },
      thumb = { highlight = { bg = '#4b4e57' }, blend = 0 },
    },
    minimap = {
      enabled = true,
      show = false, -- start hidden; <leader>us shows it
      -- left off so a toggled-on minimap stays visible instead of hiding itself
      autohide = false,
    },
  },
  config = function(_, opts)
    require('scrollbar').setup(opts)

    -- kanso-ink runs with transparent = true, so Normal has no background and
    -- the minimap would draw its dots straight over the buffer text. Give it
    -- its own ink surface plus the theme accent colors.
    local groups = {
      ScrollbarMinimapBase = { bg = '#1f1f26' }, -- inkBg1
      ScrollbarMinimapContent = { fg = '#75797f' }, -- gray4, the Comment color
      ScrollbarMinimapViewport = { bg = '#393b44' }, -- inkBg3, the Visual color
      ScrollbarMinimapCursor = { fg = '#14171d', bg = '#e6c384' }, -- inkBg0 on yellow2
    }

    -- The plugin re-creates these groups as default links on ColorScheme, so
    -- reapply ours after every colorscheme change.
    local function apply()
      for name, hl in pairs(groups) do
        vim.api.nvim_set_hl(0, name, hl)
      end
    end

    apply()
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('kanso_ink_scrollbar', { clear = true }),
      callback = apply,
    })
  end,
}
