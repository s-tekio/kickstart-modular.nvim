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
