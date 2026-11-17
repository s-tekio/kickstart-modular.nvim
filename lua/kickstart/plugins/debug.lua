-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

---@module 'lazy'
---@type LazySpec
return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',
    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',
    -- Installs the debug adapters for you
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    -- Inline variables
    'theHamsta/nvim-dap-virtual-text',
  },
  keys = {
    -- Basic debugging keymaps, feel free to change to your liking!
    { '<leader>ds', function() require('dap').continue() end, desc = 'Debug: [S]tart/Continue (F5)' },
    { '<leader>di', function() require('dap').step_into() end, desc = 'Debug: Step [I]nto (F7)' },
    { '<leader>dn', function() require('dap').step_over() end, desc = 'Debug: Step [N]ext (F8)' },
    { '<leader>do', function() require('dap').step_out() end, desc = 'Debug: Step [O]ut' },
    { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Debug: Toggle Breakpoint' },
    { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, desc = 'Debug: Set Breakpoint' },
    { '<leader>de', function() require('dapui').eval() end, desc = 'Debug: [E]valuate expression.', mode = { 'n', 'v' } },
    { '<leader>dff', function() require('dapui').float_element 'scopes' end, desc = 'Debug: [F]loat [S]copes.', mode = { 'n', 'v' } },
    { '<leader>dfk', function() require('dapui').float_element 'stacks' end, desc = 'Debug: [F]loat Sta[K]s.', mode = { 'n', 'v' } },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    { '<leader>dd', function() require('dapui').toggle() end, desc = 'Debug: See last [S]ession result.' },
    {
      '<leader>dx',
      function()
        require('dap').terminate()
        require('dapui').close()
      end,
      desc = 'Debug: [X] Stop / Terminate Session',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        'php-debug-adapter',
        'js', -- js-debug-adapter (vscode-js-debug): TS/JS, React, Node
      },
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    ---@diagnostic disable-next-line: missing-fields
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      ---@diagnostic disable-next-line: missing-fields
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Change breakpoint icons
    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    local breakpoint_icons = vim.g.have_nerd_font
        and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    dap.listeners.before.attach.dapui_config = function() dapui.open() end
    dap.listeners.before.launch.dapui_config = function() dapui.open() end
    dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
    dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
    dap.listeners.before.event_disconnected.dapui_config = function() dapui.close() end

    require('nvim-dap-virtual-text').setup()

    dap.adapters.php = {
      type = 'executable',
      command = 'node',
      -- Path for Mason to install the adapter
      args = { vim.fn.stdpath 'data' .. '/mason/packages/php-debug-adapter/extension/out/phpDebug.js' },
    }

    dap.configurations.php = {
      {
        type = 'php',
        request = 'launch',
        name = 'Listen for Xdebug',
        port = vim.g.x_debug_port or 9004,
        -- For Docker
        pathMappings = {
          ['/app'] = vim.fn.getcwd(),
        },
      },
    }

    -- JavaScript / TypeScript / React (vscode-js-debug)
    local js_debug_server = vim.fn.stdpath 'data' .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js'
    for _, adapter in ipairs { 'pwa-chrome', 'pwa-node' } do
      dap.adapters[adapter] = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        executable = {
          command = 'node',
          args = { js_debug_server, '${port}' },
        },
      }
    end

    -- js-debug only auto-detects Chrome/Edge, so point it at the installed Chromium-based browser
    local browser = vim.iter({ 'brave', 'chromium', 'google-chrome-stable', 'google-chrome' }):map(vim.fn.exepath):find(function(p) return p ~= '' end)

    -- The browser requests http://localhost:5173/src/App.tsx; js-debug maps that URL to
    -- <webRoot>/src/App.tsx. webRoot must be the host folder of the Vite project (where
    -- vite.config.* lives), not necessarily Neovim's cwd (e.g. a frontend/ subfolder).
    local function frontend_root()
      return vim.fs.root(0, { 'vite.config.ts', 'vite.config.mts', 'vite.config.js', 'vite.config.mjs', 'package.json' }) or vim.fn.getcwd()
    end

    -- Source maps generated inside Docker may reference container paths (/app/src/...).
    -- Remap them to the host folder. Override the container path with vim.g.js_docker_root.
    -- Setting this table replaces js-debug's defaults, so the webpack ones are kept here.
    local source_map_overrides = {
      [(vim.g.js_docker_root or '/app') .. '/*'] = '${webRoot}/*',
      ['webpack:///./~/*'] = '${webRoot}/node_modules/*',
      ['webpack:////*'] = '/*',
      ['webpack://?:*/*'] = '${webRoot}/*',
    }

    local js_configurations = {
      {
        type = 'pwa-chrome',
        request = 'launch',
        name = 'React: Launch Chrome against dev server',
        url = function()
          -- Vite defaults to 5173, CRA/Next to 3000
          return vim.fn.input('Dev server URL: ', 'http://localhost:5173')
        end,
        runtimeExecutable = browser,
        webRoot = frontend_root,
        sourceMaps = true,
        sourceMapPathOverrides = source_map_overrides,
      },
      {
        type = 'pwa-chrome',
        request = 'attach',
        -- Start the browser first: brave --remote-debugging-port=9222
        name = 'React: Attach to browser (--remote-debugging-port=9222)',
        port = 9222,
        webRoot = frontend_root,
        sourceMaps = true,
        sourceMapPathOverrides = source_map_overrides,
      },
      {
        type = 'pwa-node',
        request = 'launch',
        -- Plain Node scripts only (not React components / .tsx)
        name = 'Node: Launch current file',
        program = '${file}',
        cwd = '${workspaceFolder}',
        sourceMaps = true,
      },
    }

    for _, ft in ipairs { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' } do
      dap.configurations[ft] = js_configurations
    end
  end,
}
