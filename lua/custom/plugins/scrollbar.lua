return {
  'petertriho/nvim-scrollbar',
  -- v2 lands on main on 2026-11-16; remove this line after that date
  branch = 'refactor/v2',
  opts = {
    providers = {
      gitsigns = true, -- Requires gitsigns
    },
    scrollbar = {
      unit = 'screenline', -- account for closed folds and wrapped lines
    },
    -- minimap = {
    --   enabled = true,
    -- },
  },
}
