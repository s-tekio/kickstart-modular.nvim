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
      dashboard = {
        preset = {
          header = [[
 _   _ _____   _____ _____ _   _______ _____ _ 
| | | |_   _| |_   _|  ___| | / /_   _|  _  | |
| |_| | | |     | | | |__ | |/ /  | | | | | | |
|  _  | | |     | | |  __||    \  | | | | | | |
| | | |_| |_    | | | |___| |\  \_| |_\ \_/ /_|
\_| |_/\___/    \_/ \____/\_| \_/\___/ \___/(_)
]],
          -- stylua: ignore
          ---@type snacks.dashboard.Item[]
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
      picker = {
        enabled = true,
        sources = {
          files = {
            hidden = true, -- Ver archivos .env
            ignored = true, -- Ver archivos en .gitignore
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
      input = { enabled = true },
      lazygit = { enabled = true },
    },
    config = function(_, opts)
      require('snacks').setup(opts)

      local function map(mode, l, r, options)
        options = options or {}
        vim.keymap.set(mode, l, r, options)
      end

      local picker = require('snacks').picker

      -- [[ Keymaps Estándar ]]
      map('n', '<leader>fh', picker.help, { desc = 'Search [H]elp' })
      map('n', '<leader>fk', picker.keymaps, { desc = 'Search [K]eymaps' })
      map('n', '<leader>ff', picker.files, { desc = 'Search [F]iles' })
      map('n', '<leader>fp', picker.pickers, { desc = 'Search Select Picker' })
      map({ 'n', 'v' }, '<leader>fw', picker.grep_word, { desc = 'Search current [W]ord' })
      map('n', '<leader>fs', function() picker.grep { args = { '--smart-case' } } end, { desc = '[S]earch text (smart case)' })
      map('n', '<leader>fd', picker.diagnostics, { desc = 'Search [D]iagnostics' })
      map('n', '<leader>fr', picker.resume, { desc = 'Search [R]esume' })
      map('n', '<leader>f.', picker.recent, { desc = 'Search Recent Files' })
      map('n', '<leader>fc', picker.commands, { desc = 'Search [C]ommands' })
      map('n', '<leader>ft', function() picker.todo_comments { cwd = _G.get_git_root() } end, { desc = 'Todo Comments (Project Root)' })
      map(
        'n',
        '<leader>fT',
        function() picker.todo_comments { cwd = _G.get_git_root(), keywords = { 'TODO', 'FIX', 'FIXME' } } end,
        { desc = 'Todo/Fix/Fixme (Project Root)' }
      )
      map('n', '<leader><leader>', picker.buffers, { desc = '[ ] Find existing buffers' })
      map('n', '<leader>fn', function() picker.files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch [N]eovim files' })
      map('n', '<leader>/', function() picker.lines() end, { desc = '[/] Fuzzily search in current buffer' })
      map('n', '<leader>f/', function() picker.grep_buffers() end, { desc = '[S]earch [/] in Open Files' })

      -- [[ Keymaps LSP ]]
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('snacks-lsp-attach', { clear = true }),
        callback = function(event)
          local buf = event.buf
          map('n', 'gr', picker.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })
          map('n', 'gI', picker.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })
          map('n', 'gd', picker.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })
          map('n', 'gO', picker.lsp_symbols, { buffer = buf, desc = 'Open Document Symbols' })
          map('n', 'gW', picker.lsp_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })
          map('n', 'gt', picker.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
        end,
      })

      -- lazygit
      if vim.fn.executable 'lazygit' == 1 then
        map('n', '<leader>gg', function() Snacks.lazygit { cwd = _G.get_git_root() } end, { desc = 'Lazygit (Root Dir)' })
        map('n', '<leader>gG', function() Snacks.lazygit() end, { desc = 'Lazygit (cwd)' })
      end
    end,
  },
}
