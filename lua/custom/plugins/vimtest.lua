local project_to_service = {
  ['authentication-service'] = 'auth',
  ['notifications-service'] = 'noti',
  ['status-service'] = 'status',
  ['customer-satisfaction-service'] = 'cs',
  ['roles-permissions-service'] = 'rp',
  ['payments-service'] = 'payments',
  ['data-service'] = 'data',
  ['api-gateway'] = 'api-gateway',
}

--- @param project_root string Path to the root of the project
local function find_docker_compose(project_root)
  -- For perfomance reasons, always try to look for the file in root or /docker folder
  local compose_path = vim.fs.find('docker-compose.yml', { path = project_root })[1]
    or vim.fs.find('docker-compose.yml', { path = project_root .. '/docker' })[1]

  if not compose_path then
    local find_opts = {
      path = project_root,
      upward = false, -- Buscamos hacia dentro del proyecto
      limit = 1,
    }
    compose_path = vim.fs.find({ 'docker-compose.yml', 'docker-compose.yaml' }, find_opts)[1]
  end

  -- compose_path or fallback
  return compose_path or 'docker-compose.yml'
end

return {
  'vim-test/vim-test',
  config = function()
    vim.g['test#strategy'] = 'neovim'
    vim.cmd [[ let g:test#filename_modifier = ':.' ]]

    _G.docker_transform = function(cmd)
      local path = vim.api.nvim_buf_get_name(0)
      local composer_match = vim.fs.find({ 'composer.json' }, { path = path, upward = true })[1]
      if not composer_match then return cmd end

      local project_root = vim.fs.dirname(composer_match)
      local project_name = vim.fn.fnamemodify(project_root, ':t')

      -- BUSQUEDA DEL SERVICIO
      local service = nil
      local docker_network_root_path = ''
      local compose_path = nil

      if project_to_service[project_name] then
        -- Alfred microservice's structure
        service = project_to_service[project_name]
        docker_network_root_path = os.getenv '_ROOT' or ''
        compose_path = docker_network_root_path .. '/backend/docker-compose.yml'
      elseif vim.g.php_debug_service_name and vim.g.php_debug_service_name ~= '' then
        -- Configured using :PhpService
        service = vim.g.php_debug_service_name
      else
        -- Fallback to folder name + WARNING
        service = project_name
        vim.schedule(function() vim.notify("Using '" .. service .. "' as Docker container's name. If it fails, use :PhpService", vim.log.levels.WARN) end)
      end

      if compose_path == nil then compose_path = find_docker_compose(project_root) end

      -- 1. DETECCIÓN DEL XML (Priorizamos functional-tests | unit-tests si existen)
      local config_file = 'phpunit.xml'
      if vim.fn.filereadable(project_root .. '/tests/functional-tests.xml') == 1 then
        config_file = 'tests/functional-tests.xml'
      elseif vim.fn.filereadable(project_root .. '/tests/unit-tests.xml') == 1 then
        config_file = 'tests/unit-tests.xml'
      end

      -- 2. LIMPIEZA DE RUTA (Extraemos solo lo relativo a partir de tests/ o src/)
      local relative_path = cmd:match '(tests/[^%s:]+)' or cmd:match '(src/[^%s:]+)'

      -- 3. EXTRACCIÓN DEL FILTRO
      local filter = cmd:match '%-%-filter%s+([^%s]+)'
      local filter_arg = filter and ('--filter ' .. filter) or ''

      -- 4. RECONSTRUCCIÓN DEL COMANDO
      -- Importante: El flag -c va JUSTO antes de la ruta del archivo o al final de los flags
      local final_cmd = string.format(
        'docker compose -f %s exec -i -w /app -e APP_ENV=test %s /app/vendor/bin/phpunit -c /app/%s %s %s',
        compose_path,
        service,
        config_file,
        filter_arg,
        relative_path or ''
      )

      -- El truco del '#' para anular la basura que añada vim-test al final
      return final_cmd .. ' #'
    end

    vim.cmd [[
      function! LuaTransform(cmd)
        return v:lua.docker_transform(a:cmd)
      endfunction
      let g:test#custom_transformations = {'docker': function('LuaTransform')}
      let g:test#transformation = 'docker'
    ]]

    local map = vim.keymap.set
    map('n', '<leader>tt', ':TestNearest<CR>')
    map('n', '<leader>tf', ':TestFile<CR>')
    map('n', '<leader>ts', ':TestSuite<CR>')
    map('n', '<leader>tl', ':TestLast<CR>')
  end,
}
