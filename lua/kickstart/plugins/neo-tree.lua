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
    { '<leader>\\', ':Neotree toggle<CR>', desc = 'NeoTree toggle', silent = true },
    { '<leader>nr', ':Neotree reveal<CR>', desc = '[N]eoTree [R]eveal', silent = true },
    { '<leader>gs', ':Neotree float git_status<CR>', desc = '[N]eoTree [G]it [S]tatus', silent = true },
  },
  ---@module 'neo-tree'
  ---@type neotree.Config
  opts = {
    filesystem = {
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['<leader>tt'] = {
            desc = 'run_tests_in_folder',
            function(state)
              local node = state.tree:get_node()
              if node == nil then return end

              local full_path = node:get_id()
              -- Get the project name so the path can be trimmed
              -- For example, for 'authentication-service' we want everything after it
              local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
              local relative_path = full_path:match('.*/' .. project_name .. '/(.+)') or full_path

              -- Now call TestFile with the already cleaned path
              vim.api.nvim_command('TestFile ' .. relative_path)
            end,
          },
          ['<leader>fs'] = {
            desc = 'search_in_folder',
            function(state)
              local node = state.tree:get_node()
              if node == nil then return end

              local full_path = node:get_id()
              local target_dir

              -- If it's a directory, use it directly.
              -- If it's a file, get its parent directory.
              if node.type == 'directory' then
                target_dir = full_path
              else
                target_dir = vim.fn.fnamemodify(full_path, ':h')
              end

              -- Launch snacks picker targeting that specific directory
              require('snacks').picker.grep {
                cwd = target_dir,
                hidden = true,
                ignored = true,
                exclude = { '.git', 'node_modules', '**/cache/**', '**/log/**', '**/logs/**' },
                args = { '--smart-case' },
                title = 'Grep in ' .. vim.fn.fnamemodify(target_dir, ':t'),
              }
            end,
          },
        },
      },
    },
  },
}
