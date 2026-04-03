-- custom/autocommands.lua

local my_custom_commands = {
  {
    title = "PhpService",
    cmd = "PhpService",
    desc = "Configure Docker Container (Service)"
  },
  {
    title = "XDebugPort",
    cmd = "XDebugPort",
    desc = "Change XDebug Listening Port (default: 9004)"
  },
}

vim.api.nvim_create_user_command('MyTools', function()
  local display_items = {}
  for _, item in ipairs(my_custom_commands) do
    table.insert(display_items, string.format("%-12s │ %s", item.title, item.desc))
  end

  vim.ui.select(display_items, {
    prompt = 'My Neovim Tools:',
    format_item = function(item)
      return item
    end,
  }, function(choice, idx)
    if choice and idx then
      local command = my_custom_commands[idx].cmd
      vim.cmd(command)
    end
  end)
end, { desc = "Open custom tools menu" })

-- vim.api.nvim_create_user_command('MyTools', function()
--   local choices = {}
--   local cmd_map = {}
--
--   ---@diagnostic disable-next-line:unused-local
--   for i, item in ipairs(my_custom_commands) do
--     local text = string.format("%-15s — %s", item.title, item.desc)
--     table.insert(choices, text)
--     cmd_map[text] = item.cmd
--   end
--
--   local opts = {
--     prompt = "My Neovim Tools",
--   }
--
--   local on_choice = function(choice)
--     if choice and cmd_map[choice] then
--       vim.cmd(cmd_map[choice])
--     end
--   end
--
--   Snacks.picker.select(choices, opts, on_choice)
-- end, { desc = "Open custom tools menu" })

vim.keymap.set('n', '<leader>mm', ':MyTools<CR>', { desc = 'My Custom Tools Menu' })

----------------------------
--- Commands Definitions ---
----------------------------
vim.api.nvim_create_user_command('PhpService', function()
  vim.ui.input({
    prompt = "Enter Docker container's name: ",
    default = vim.g.php_debug_service_name or "",
  }, function(input)
    if input and input ~= "" then
      vim.g.php_debug_service_name = input
      vim.notify('PHP service configured: ' .. input, vim.log.levels.INFO)
    end
  end)
end, {})

vim.api.nvim_create_user_command('XDebugPort', function() -- Nota: mejor sin espacio en el nombre del comando
  vim.ui.input({
    prompt = "Enter port to use by XDebug: ",
    -- Asegúrate de que el default sea un string para el input
    default = tostring(vim.g.x_debug_port or 9004),
  }, function(input)
    if input and input ~= "" then
      local port_number = tonumber(input)
      vim.g.x_debug_port = port_number

      -- Update DAP
      local dap = require('dap')
      if dap.configurations.php and dap.configurations.php[1] then
        dap.configurations.php[1].port = port_number
      end

      vim.notify('XDebug port updated to: ' .. port_number, vim.log.levels.INFO)
    end
  end)
end, {})
