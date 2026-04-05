--
-- custom/autocommands.lua
--

-- mappings
vim.keymap.set('n', '<leader>mm', ':MyTools<CR>', { desc = 'My Custom Tools Menu' })
vim.keymap.set('n', '<leader>ra', ':PhpActions<CR>', { desc = '[R]efactor [A]ctions (Phpactor)' })

-- local variables
local my_custom_commands = {
  {
    title = 'PhpService',
    cmd = 'PhpService',
    desc = 'Configure Docker Container (Service)',
  },
  {
    title = 'XDebugPort',
    cmd = 'XDebugPort',
    desc = 'Change XDebug Listening Port (default: 9004)',
  },
}

local phpactor_actions = {
  {
    title = 'Move Class',
    cmd = 'PhpactorMoveFile', -- We go back to the command name
    desc = 'Move file and update namespaces across the project',
  },
  {
    title = 'Copy Class',
    cmd = 'PhpactorCopyClass',
    desc = 'Create a copy of the current class in a new path',
  },
  {
    title = 'Import Class',
    cmd = 'PhpactorImportClass',
    desc = 'Imports class or asks to define an alias if already imported',
  },
  {
    title = 'Class New',
    cmd = 'PhpactorClassNew',
    desc = 'Create a new class following PSR-4 standard',
  },
}

-- selectors commands
vim.api.nvim_create_user_command('MyTools', function()
  local display_items = {}
  for _, item in ipairs(my_custom_commands) do
    table.insert(display_items, string.format('%-12s │ %s', item.title, item.desc))
  end

  vim.ui.select(display_items, {
    prompt = '󱁤 My Neovim Tools:',
    format_item = function(item) return item end,
  }, function(choice, idx)
    if choice and idx then
      local command = my_custom_commands[idx].cmd
      vim.cmd(command)
    end
  end)
end, { desc = 'Open custom tools menu' })

vim.api.nvim_create_user_command('PhpActions', function()
  local display_items = {}

  for _, item in ipairs(phpactor_actions) do
    table.insert(display_items, string.format('%-15s │ %s', item.title, item.desc))
  end

  vim.ui.select(display_items, {
    prompt = '󰑭 Phpactor Refactor:',
  }, function(choice, idx)
    if choice and idx then
      local command = phpactor_actions[idx].cmd

      -- We use pcall (protected call) to avoid breaking the UI if the command
      -- fails or if the user cancels the action.
      local ok, err = pcall(function() vim.cmd(command) end)

      if not ok then vim.notify('Phpactor Error: ' .. tostring(err), vim.log.levels.ERROR) end
    end
  end)
end, { desc = 'Open Phpactor refactor menu' })

----------------------------
--- Commands Definitions ---
----------------------------
vim.api.nvim_create_user_command('PhpService', function()
  vim.ui.input({
    prompt = "Enter Docker container's name: ",
    default = vim.g.php_debug_service_name or '',
  }, function(input)
    if input and input ~= '' then
      vim.g.php_debug_service_name = input
      vim.notify('PHP service configured: ' .. input, vim.log.levels.INFO)
    end
  end)
end, {})

vim.api.nvim_create_user_command('XDebugPort', function() -- Nota: mejor sin espacio en el nombre del comando
  vim.ui.input({
    prompt = 'Enter port to use by XDebug: ',
    -- Asegúrate de que el default sea un string para el input
    default = tostring(vim.g.x_debug_port or 9004),
  }, function(input)
    if input and input ~= '' then
      local port_number = tonumber(input)
      vim.g.x_debug_port = port_number

      -- Update DAP
      local dap = require 'dap'
      if dap.configurations.php and dap.configurations.php[1] then dap.configurations.php[1].port = port_number end

      vim.notify('XDebug port updated to: ' .. port_number, vim.log.levels.INFO)
    end
  end)
end, {})
