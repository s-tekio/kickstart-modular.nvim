return {
  'vim-test/vim-test',
  config = function()
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

    vim.g['test#strategy'] = 'neovim'
    vim.cmd([[ let g:test#filename_modifier = ':.' ]])

    _G.docker_transform = function(cmd)
      local path = vim.api.nvim_buf_get_name(0)
      local composer_match = vim.fs.find({ 'composer.json' }, { path = path, upward = true })[1]
      if not composer_match then return cmd end

      local project_root = vim.fs.dirname(composer_match)
      local project_name = vim.fn.fnamemodify(project_root, ':t')
      local service = project_to_service[project_name] or project_name
      local root_path = os.getenv('_ROOT') or ''
      local compose_path = root_path .. '/backend/docker-compose.yml'

      -- 1. DETECCIÓN DEL XML (Priorizamos functional-tests si existe)
      local config_file = 'phpunit.xml'
      if vim.fn.filereadable(project_root .. '/tests/functional-tests.xml') == 1 then
        config_file = 'tests/functional-tests.xml'
      end

      -- 2. LIMPIEZA DE RUTA (Extraemos solo lo relativo a partir de tests/ o src/)
      local relative_path = cmd:match("(tests/[^%s:]+)") or cmd:match("(src/[^%s:]+)")

      -- 3. EXTRACCIÓN DEL FILTRO
      local filter = cmd:match("%-%-filter%s+([^%s]+)")
      local filter_arg = filter and ("--filter " .. filter) or ""

      -- 4. RECONSTRUCCIÓN DEL COMANDO
      -- Importante: El flag -c va JUSTO antes de la ruta del archivo o al final de los flags
      local final_cmd = string.format(
        'docker compose -f %s exec -i -w /app -e APP_ENV=test %s /app/vendor/bin/phpunit -c /app/%s %s %s',
        compose_path,
        service,
        config_file,
        filter_arg,
        relative_path or ""
      )

      -- El truco del '#' para anular la basura que añada vim-test al final
      return final_cmd .. " #"
    end

    vim.cmd([[
      function! LuaTransform(cmd)
        return v:lua.docker_transform(a:cmd)
      endfunction
      let g:test#custom_transformations = {'docker': function('LuaTransform')}
      let g:test#transformation = 'docker'
    ]])

    local map = vim.keymap.set
    map('n', '<leader>tt', ':TestNearest<CR>')
    map('n', '<leader>tf', ':TestFile<CR>')
    map('n', '<leader>ts', ':TestSuite<CR>')
    map('n', '<leader>tl', ':TestLast<CR>')
  end
}
