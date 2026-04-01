---@module 'lazy'
---@type LazySpec
return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
		--- @diagnostic disable-next-line
    ---@type snacks.Config
    opts = {
      picker = {
        enabled = true,
        sources = {
          files = {
            hidden = true,   -- Ver archivos .env
            ignored = true,  -- Ver archivos en .gitignore
            -- Excluimos manualmente lo que NO queremos ver nunca
            exclude = { '.git', 'vendor', 'node_modules', '.phpunit.result.cache' },
          },
          grep = {
            hidden = true,
            ignored = true,
            exclude = { '.git', 'vendor', 'node_modules' },
          },
        },
      },
      notifier = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
    config = function(_, opts)
      require('snacks').setup(opts)

      local picker = require('snacks').picker

      -- [[ Keymaps Estándar ]]
      vim.keymap.set('n', '<leader>fh', picker.help, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>fk', picker.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>ff', picker.files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ft', picker.pickers, { desc = '[S]earch [S]elect Picker' })
      vim.keymap.set({ 'n', 'v' }, '<leader>fw', picker.grep_word, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>fs', picker.grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>fd', picker.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>fr', picker.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>f.', picker.recent, { desc = '[S]earch Recent Files' })
      vim.keymap.set('n', '<leader>fc', picker.commands, { desc = '[S]earch [C]ommands' })
      vim.keymap.set('n', '<leader><leader>', picker.buffers, { desc = '[ ] Find existing buffers' })

      -- [[ HISTORIAL DE NOTIFICACIONES ]]
      vim.keymap.set('n', ',n', function() require('snacks').notifier.show_history() end, { desc = 'Notification History' })

      -- Búsqueda específica en configuración de Neovim
      vim.keymap.set('n', '<leader>fn', function()
        picker.files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })

      -- Búsqueda en el buffer actual (sustituye al dropdown theme de telescope)
      vim.keymap.set('n', '<leader>/', function()
        picker.lines()
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- Grep en archivos abiertos
      vim.keymap.set('n', '<leader>f/', function()
        picker.grep_buffers()
      end, { desc = '[S]earch [/] in Open Files' })

      -- [[ Keymaps LSP ]]
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('snacks-lsp-attach', { clear = true }),
        callback = function(event)
          local buf = event.buf
          vim.keymap.set('n', '<leader>gr', picker.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })
          vim.keymap.set('n', '<leader>gI', picker.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })
          vim.keymap.set('n', '<leader>gd', picker.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })
          vim.keymap.set('n', '<leader>gO', picker.lsp_symbols, { buffer = buf, desc = 'Open Document Symbols' })
          vim.keymap.set('n', '<leader>gW', picker.lsp_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })
          vim.keymap.set('n', '<leader>gt', picker.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
        end,
      })
    end,
  },
}
