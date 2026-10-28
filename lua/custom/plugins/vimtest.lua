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

  return compose_path
end

--- Joins a path declared in a PHPUnit XML with the XML's directory, relative to the project root
--- @param xml_dir string Directory of the XML file, relative to the project root ('' when at root)
--- @param declared string Path as written in the XML
local function resolve_xml_path(xml_dir, declared)
  local joined = xml_dir ~= '' and (xml_dir .. '/' .. declared) or declared
  return (vim.fn.simplify(joined):gsub('^%./', ''):gsub('/+$', ''))
end

--- @param path string
--- @param dir string
local function is_under(path, dir) return path == dir or vim.startswith(path, dir .. '/') end

--- Paths declared in a PHPUnit XML's <testsuites>, relative to the project root
--- @param project_root string
--- @param config_file string Config path relative to the project root
--- @return { included: string[], excluded: string[] }|nil
local function read_suites(project_root, config_file)
  local ok, lines = pcall(vim.fn.readfile, project_root .. '/' .. config_file)
  if not ok then return nil end

  local suites = table.concat(lines, '\n'):match '<testsuites>(.-)</testsuites>'
  if not suites then return nil end

  local xml_dir = vim.fs.dirname(config_file)
  if xml_dir == '.' then xml_dir = '' end

  local result = { included = {}, excluded = {} }
  for excluded in suites:gmatch '<exclude[^>]*>%s*(.-)%s*</exclude>' do
    table.insert(result.excluded, resolve_xml_path(xml_dir, excluded))
  end
  for _, tag in ipairs { 'directory', 'file' } do
    for declared in suites:gmatch('<' .. tag .. '[^>]*>%s*(.-)%s*</' .. tag .. '>') do
      table.insert(result.included, resolve_xml_path(xml_dir, declared))
    end
  end

  return result
end

--- Whether the suites include the given path (and do not exclude it)
--- @param relative_path string Test path relative to the project root
local function suites_own_path(suites, relative_path)
  for _, excluded in ipairs(suites.excluded) do
    if is_under(relative_path, excluded) then return false end
  end
  for _, included in ipairs(suites.included) do
    if is_under(relative_path, included) then return true end
  end

  return false
end

--- Whether every suite path lives strictly inside the given folder (e.g. 'tests' holding 'tests/Application')
--- @param relative_path string Folder path relative to the project root
local function suites_inside_path(suites, relative_path)
  if #suites.included == 0 then return false end
  for _, included in ipairs(suites.included) do
    if included == relative_path or not is_under(included, relative_path) then return false end
  end

  return true
end

return {
  'vim-test/vim-test',
  config = function()
    vim.g['test#strategy'] = 'neovim'
    vim.g['test#php#phpunit#options'] = '--testdox'

    vim.cmd [[ let g:test#filename_modifier = ':.' ]]

    _G.docker_transform = function(cmd)
      local current_buf_path = vim.api.nvim_buf_get_name(0)
      -- CWD fallback when tests are executed from neo-tree
      local lookup_path = (current_buf_path ~= '' and vim.bo.buftype == '') and current_buf_path or vim.fn.getcwd()

      local composer_match = vim.fs.find({ 'composer.json' }, { path = lookup_path, upward = true })[1]
      if not composer_match then return cmd end

      local project_root = vim.fs.dirname(composer_match)
      local project_name = vim.fn.fnamemodify(project_root, ':t')

      -- SERVICE LOOKUP
      local service = nil
      local docker_network_root_path = ''
      local compose_path = nil
      local warning_message = ''

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
        warning_message = "Using '" .. service .. "' as Docker container's name. If it fails, use :PhpService"
      end

      if compose_path == nil then compose_path = find_docker_compose(project_root) end

      -- 1. PATH CLEANUP (keep only what follows tests/ or src/, or take the file as given)
      local relative_path = cmd:match '(tests[^%s:#]*)' or cmd:match '(src[^%s:#]*)' or cmd:match '([^%s:#]+%.php)'

      -- 2. XML DETECTION (functional-tests | unit-tests take priority when present)
      local candidates = {
        'tests/phpunit.xml',
        'tests/functional-tests.xml',
        'tests/unit-tests.xml',
        'phpunit.dist.xml',
        'phpunit.xml.dist',
      }
      local existing = vim.tbl_filter(function(c) return vim.fn.filereadable(project_root .. '/' .. c) == 1 end, candidates)

      -- Walk the configs in priority order:
      --   * the first one whose <testsuites> contain the test path wins (run with that path)
      --   * configs whose whole suites live inside the folder found before that are run as full suites instead
      --     (e.g. 'tests/' holding unit-tests.xml and functional-tests.xml suites); the path is dropped because
      --     PHPUnit ignores <exclude> for explicit paths and would run the same tests twice
      local config_files = {}
      local run_whole_suites = false
      if relative_path then
        for _, c in ipairs(existing) do
          local suites = read_suites(project_root, c)
          if suites and suites_own_path(suites, relative_path) then
            if not run_whole_suites then config_files = { c } end
            break
          elseif suites and suites_inside_path(suites, relative_path) then
            table.insert(config_files, c)
            run_whole_suites = true
          end
        end
      end

      -- Whole-suite run (no test path) with split unit/functional configs: run both instead of only the first
      if not relative_path and vim.tbl_contains(existing, 'tests/unit-tests.xml') and vim.tbl_contains(existing, 'tests/functional-tests.xml') then
        config_files = { 'tests/unit-tests.xml', 'tests/functional-tests.xml' }
        run_whole_suites = true
      end

      if #config_files == 0 then config_files = { existing[1] } end
      local test_path = run_whole_suites and '' or (relative_path or '')

      -- 3. FILTER EXTRACTION
      local filter = cmd:match '%-%-filter%s+([^%s]+)'
      local filter_arg = filter and ('--filter ' .. filter) or ''

      -- 4. COMMAND REBUILD
      -- Important: the -c flag goes right before the file path, or at the end of the flags
      if compose_path ~= nil and warning_message ~= '' then
        vim.schedule(function() vim.notify(warning_message, vim.log.levels.WARN) end)
      end

      local function phpunit_cmd(cfg)
        if compose_path == nil then
          return string.format('vendor/bin/phpunit -c %s %s --testdox --colors=always %s', cfg, filter_arg, test_path)
        end

        return string.format(
          'docker compose -f %s exec -i -w /app -e APP_ENV=test %s /app/vendor/bin/phpunit -c /app/%s %s --testdox --colors=always %s',
          compose_path,
          service,
          cfg,
          filter_arg,
          test_path
        )
      end

      local final_cmd = phpunit_cmd(config_files[1])
      if #config_files > 1 then
        -- Every suite runs even if a previous one fails; the overall exit code fails if any did.
        -- Wrapped in 'sh -c' so it works whatever the user's shell is (e.g. fish has no '{ ...; }' or '$?')
        local parts = { final_cmd .. '; ec=$?' }
        for i = 2, #config_files do
          table.insert(parts, phpunit_cmd(config_files[i]) .. ' || ec=$?')
        end
        final_cmd = string.format("sh -c '%s; [ $ec -eq 0 ]'", table.concat(parts, '; '))
      end
      if compose_path == nil then final_cmd = string.format('cd %s && %s', project_root, final_cmd) end

      -- The '#' trick swallows whatever junk vim-test appends at the end
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
