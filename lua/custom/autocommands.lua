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
