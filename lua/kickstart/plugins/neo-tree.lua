-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

---@module 'lazy'
---@type LazySpec
return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree toggle<CR>', desc = 'NeoTree toggle', silent = true },
  },
  ---@module 'neo-tree'
  ---@type neotree.Config
  opts = {
    filesystem = {
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['<leader>tt'] = function(state)
            local node = state.tree:get_node()
            if node == nil then
              return
            end

            local full_path = node:get_id()
            -- Obtenemos el nombre del proyecto para recortar la ruta
            -- Si el proyecto es 'authentication-service', queremos lo que va después
            local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
            local relative_path = full_path:match(".*/" .. project_name .. "/(.+)") or full_path

            -- Ahora llamamos a TestFile con la ruta ya limpia
            vim.api.nvim_command("TestFile " .. relative_path)
          end,
        },
      },
    },
  },
}
