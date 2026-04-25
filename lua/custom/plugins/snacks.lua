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
░  ░░░░  ░░        ░░░░░░░░        ░░        ░░  ░░░░  ░░        ░░░      ░░
▒  ▒▒▒▒  ▒▒▒▒▒  ▒▒▒▒▒▒▒▒▒▒▒▒▒▒  ▒▒▒▒▒  ▒▒▒▒▒▒▒▒  ▒▒▒  ▒▒▒▒▒▒  ▒▒▒▒▒  ▒▒▒▒  ▒
▓        ▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓      ▓▓▓▓     ▓▓▓▓▓▓▓▓  ▓▓▓▓▓  ▓▓▓▓  ▓
█  ████  █████  ██████████████  █████  ████████  ███  ██████  █████  ████  █
█  ████  ██        ███████████  █████        ██  ████  ██        ███      ██
                                       
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
            exclude = { '.git', 'vendor', 'node_modules', '.phpunit.result.cache', '**/cache/**', '**/log/**', '**/logs/**' },
          },
          grep = {
            hidden = true,
            ignored = true,
            exclude = { '.git', 'vendor', 'node_modules', '**/cache/**', '**/log/**', '**/logs/**' },
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
      local search_files = function()
        local snacks = require 'snacks'
        local opts = {}

        local mode = vim.api.nvim_get_mode().mode
        local is_visual = mode:match '^[vV]'

        if is_visual then opts.search = snacks.picker.util.visual().text end

        snacks.picker.files(opts)
      end

      -- [[ Keymaps Estándar ]]
      map('n', '<leader>fh', picker.help, { desc = 'Search [H]elp' })
      map('n', '<leader>fk', picker.keymaps, { desc = 'Search [K]eymaps' })
      map({ 'n', 'x' }, '<leader>ff', search_files, { desc = 'Search [F]iles' })
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
          map('n', 'gs', picker.lsp_symbols, { buffer = buf, desc = 'Open Document Symbols' })
          map('n', 'gW', picker.lsp_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })
          map('n', 'gy', picker.lsp_type_definitions, { buffer = buf, desc = '[G]oto T[y]pe Definition' })
        end,
      })

      map('n', 'gt', function()
        local current_file = vim.fn.expand '%:t:r'
        local extension = vim.fn.expand '%:e'
        if current_file == '' or extension == '' then return end

        local is_test = current_file:match 'Test$'
        local target_name = is_test and current_file:gsub('Test$', '') or (current_file .. 'Test')
        local target_filename = target_name .. '.' .. extension

        -- 1. Find exact matches using 'fd'
        -- Added '.' to specify current directory and '--max-depth 20' for extra safety
        local results = vim.fn.systemlist(string.format("fd --max-depth 20 --glob '**/%s' .", target_filename))

        -- 2. Fallback to 'git ls-files' if fd fails
        if #results == 0 or (results[1] and results[1]:match '^error:') then
          results = vim.fn.systemlist(string.format("git ls-files '*/%s' '%s'", target_filename, target_filename))
        end

        -- 3. Safety filter: remove empty lines or error messages
        local valid_files = {}
        for _, path in ipairs(results) do
          if path ~= '' and not path:match '^error:' and not path:match '^Usage:' then table.insert(valid_files, path) end
        end

        if #valid_files == 0 then
          vim.notify('No matching file found for: ' .. target_filename, vim.log.levels.WARN)
          return
        end

        -- 4. Map the valid paths to Snacks items
        local items = {}
        for _, path in ipairs(valid_files) do
          table.insert(items, {
            text = path,
            file = vim.fn.fnamemodify(path, ':p'),
          })
        end

        -- 5. Open the picker
        require('snacks').picker {
          title = 'Goto ' .. (is_test and 'Source Class' or 'Test File'),
          items = items,
          layout = { preset = 'vscode' },
          format = 'file',
        }
      end, { desc = 'Git: [G]oto [t]est or source file' })

      -- [[ GO TO TETST ]] - snacks picker files version
      -- map('n', 'gt', function()
      --   local current_file = vim.fn.expand '%:t:r'
      --   if current_file == '' then return end
      --
      --   local is_test = current_file:match 'Test$'
      --   -- Set target: if we are in Test, look for Class. If in Class, look for Test.
      --   local target_name = is_test and current_file:gsub('Test$', '') or (current_file .. 'Test')
      --
      --   picker.files {
      --     title = is_test and 'Go to Source Class' or 'Go to Test File',
      --     -- Initialize the picker with the target name
      --     pattern = target_name,
      --     -- [STRICT MATCHING]
      --     -- We use 'transform' to filter results. Returning nil removes the item from the list.
      --     transform = function(item)
      --       -- Get the actual filename from the item (using .file is more reliable than .text)
      --       local path = item.file or item.text
      --       local item_name = vim.fn.fnamemodify(path, ':t:r')
      --
      --       -- 1. Strict Equality: The filename must be EXACTLY our target name.
      --       -- This eliminates 'ListUserIntercomsController' when searching for 'ListUsersController'.
      --       if item_name ~= target_name then return nil end
      --
      --       -- 2. Prevent self-matching: If we are searching for the source class from a test,
      --       -- ensure we don't accidentally include the test file itself.
      --       if is_test and item_name:match 'Test$' then return nil end
      --
      --       return item
      --     end,
      --   }
      -- end, { desc = 'Git: [G]oto [t]est or source file' })

      -- lazygit
      if vim.fn.executable 'lazygit' == 1 then
        map('n', '<leader>gg', function() Snacks.lazygit { cwd = _G.get_git_root() } end, { desc = 'Lazygit (Root Dir)' })
        map('n', '<leader>gG', function() Snacks.lazygit() end, { desc = 'Lazygit (cwd)' })
      end

      -- [[ Toggles ]]

      -- Global Toggle
      Snacks.toggle({
        name = 'Auto Format (Global)',
        get = function() return vim.g.autoformat ~= false end,
        set = function(state) vim.g.autoformat = state end,
      }):map '<leader>uf'

      -- Buffer Toggle
      Snacks.toggle({
        name = 'Auto Format (Buffer)',
        get = function() return vim.b.autoformat ~= false end,
        set = function(state) vim.b.autoformat = state end,
      }):map '<leader>uF'

      -- Other useful toggles (Optional, but very "LazyVim style")
      Snacks.toggle.diagnostics():map '<leader>ud'
    end,
  },
}
