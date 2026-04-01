vim.api.nvim_create_user_command('PhpService', function(opts)
  vim.g.php_debug_service_name = opts.args
  print('Servicio PHP seteado a: ' .. opts.args)
end, { nargs = 1 })
