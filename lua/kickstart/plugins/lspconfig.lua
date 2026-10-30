-- LSP Plugins
---@module 'lazy'
---@type LazySpec
return {
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      {
        'mason-org/mason.nvim',
        ---@module 'mason.settings'
        ---@type MasonSettings
        ---@diagnostic disable-next-line: missing-fields
        opts = {},
      },
      -- Maps LSP server names between nvim-lspconfig and Mason package names.
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- JSON/YAML schemas from SchemaStore (tsconfig, package.json, docker-compose, ...).
      'b0o/SchemaStore.nvim',
    },
    config = function()
      -- Brief aside: **What is LSP?**
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client:supports_method('textDocument/inlayHint', event.buf) then
            map('<leader>lth', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
          end

          map('<leader>lr', '<cmd>lsp restart<CR>', '[L]SP [R]estart')
          map('<leader>li', '<cmd>checkhealth vim.lsp<CR>', '[L]SP [I]nfo')
          -- map('<leader>ll', '<cmd>lua vim.cmd("tabnew " .. vim.lsp.get_log_path())<CR>', '[L]SP [L]og')
          map('<leader>ll', '<cmd>LspLog<CR>', '[L]SP [L]og')

          vim.api.nvim_create_user_command('LspLog', function() vim.cmd.tabnew { vim.lsp.log.get_filename() } end, {
            desc = 'Opens the Nvim LSP client log.',
          })

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          if client and client:supports_method('textDocument/documentHighlight', event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end
        end,
      })

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --  See `:help lsp-config` for information about keys and how to configure
      ---@type table<string, vim.lsp.Config>
      local servers = {
        stylua = {}, -- Used to format Lua code
        marksman = {}, -- for markdown
        -- Special Lua Config, as recommended by neovim help docs
        lua_ls = {
          on_init = function(client)
            if client.workspace_folders then
              local path = client.workspace_folders[1].name
              if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
            end

            client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
              runtime = {
                version = 'LuaJIT',
                path = { 'lua/?.lua', 'lua/?/init.lua' },
              },
              workspace = {
                checkThirdParty = false,
                -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
                --  See https://github.com/neovim/nvim-lspconfig/issues/3189
                library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
                  '${3rd}/luv/library',
                  '${3rd}/busted/library',
                }),
              },
            })
          end,
          settings = {
            Lua = {},
          },
        },

        intelephense = {
          root_markers = { '.env.local', 'symfony.lock', '.git', 'composer.json' },
          init_options = {
            licenceKey = os.getenv 'INTELEPHENSE_LICENSE' or '',
            storagePath = vim.fn.stdpath 'cache' .. '/intelephense',
          },
          settings = {
            intelephense = {
              files = {
                maxSize = 5000000,
              },
              format = {
                enable = false,
              },
              environment = {
                includePaths = { 'vendor' },
                phpVersion = '8.2.28',
              },
              references = {
                exclude = {},
              },
              -- Inlay hints (premium licence required)
              inlayHint = {
                returnTypes = true,
                parameterTypes = true,
                parameterNames = true,
              },
            },
          },
        },

        -- Used for PHP refactoring
        phpactor = {
          root_markers = { '.env.local', 'symfony.lock', '.git', 'composer.json' },
          -- Disable autocompletion (intelephense used for this)
          capabilities = {
            textDocument = {
              completion = {
                completionItem = {
                  snippetSupport = false,
                },
              },
            },
          },
          handlers = {
            ['textDocument/publishDiagnostics'] = function() end, -- disable diagnostics
          },
          ---@diagnostic disable-next-line:unused-local
          on_attach = function(client, bufnr)
            -- Disable some capabilities (intelephense used)
            client.server_capabilities.renameProvider = false
            client.server_capabilities.completionProvider = nil
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
            client.server_capabilities.definitionProvider = false
            client.server_capabilities.implementationProvider = false
            client.server_capabilities.typeDefinitionProvider = false
            client.server_capabilities.referencesProvider = false
            client.server_capabilities.documentSymbolProvider = false
            client.server_capabilities.workspaceSymbolProvider = false
            client.server_capabilities.semanticTokensProvider = nil
          end,
        },

        -- Make sure to execute :TSInstall yaml
        yamlls = {
          settings = {
            yaml = {
              -- The bundled schema store is replaced by SchemaStore.nvim, which keeps its copy
              -- of the schemas up to date and resolves them offline.
              schemaStore = {
                enable = false,
                url = '',
              },
              schemas = require('schemastore').yaml.schemas(),
            },
          },
        },
        html = {
          filetypes = { 'html', 'twig', 'javascriptreact' },
          root_markers = { '.env.local', 'symfony.lock', '.git', 'composer.json', 'package.json' },
        },

        -- CSS, SCSS, LESS
        cssls = {
          root_markers = { '.env.local', 'symfony.lock', '.git', 'composer.json', 'package.json' },
        },

        -- JavaScript / TypeScript
        -- ts_ls is the current name of tsserver. vtsls is a drop-in alternative if you ever need
        -- a different treatment of tsconfig project references; enable only one of the two.
        ts_ls = {
          root_markers = { '.env.local', 'symfony.lock', '.git', 'composer.json', 'package.json' },
          -- Lets tsserver resolve `.astro` imports from .ts/.js files with their real types.
          -- The plugin ships inside Mason's astro-language-server package.
          init_options = {
            plugins = {
              {
                name = '@astrojs/ts-plugin',
                location = vim.fn.stdpath 'data' .. '/mason/packages/astro-language-server',
              },
            },
          },
        },

        -- Astro: handles the TypeScript inside `.astro` files itself (ts_ls only covers .ts/.js).
        -- It refuses to start without a TypeScript SDK; prefer the project's node_modules and fall
        -- back to the copy bundled with Mason's typescript-language-server.
        astro = {
          -- Declared here so `before_init` always has a table to mutate: Neovim binds
          -- `initializationOptions` to this exact `init_options` *before* calling `before_init`,
          -- so the mutation has to happen in place. Reassigning `config.init_options` (for example
          -- with `vim.tbl_deep_extend`) changes nothing on the wire and the server still fails with
          -- "The `typescript.tsdk` init option is required".
          init_options = { typescript = {} },
          before_init = function(_, config)
            local typescript = config.init_options.typescript
            if typescript.tsdk then return end
            local tsdk = require('lspconfig.util').get_typescript_server_path(config.root_dir)
            if tsdk == '' then tsdk = vim.fn.stdpath 'data' .. '/mason/packages/typescript-language-server/node_modules/typescript/lib' end
            typescript.tsdk = tsdk
          end,
        },

        -- Tailwind CSS: class completion, hover docs and lint for the utilities used in JSX/TSX.
        -- Tailwind v4 keeps its theme in CSS (`@import 'tailwindcss'`), so the server discovers
        -- the entry point by itself. Pin it explicitly only if discovery ever fails:
        --   settings = { tailwindCSS = { experimental = { configFile = 'src/index.css' } } },
        -- The default filetype list also covers Blade/PHP templates, which would start a Node
        -- server on every PHP file of the Symfony projects, so keep it to the web stack.
        tailwindcss = {
          filetypes = { 'html', 'css', 'scss', 'less', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'astro' },
        },

        -- JSON with SchemaStore validation (tsconfig*, package.json, .oxlintrc.json, ...).
        jsonls = {
          settings = {
            json = {
              schemas = require('schemastore').json.schemas(),
              validate = { enable = true },
            },
          },
        },

        -- oxlint ships its own language server and prefers the project's binary from
        -- node_modules/.bin, so the reported rules match what `npm run lint` enforces.
        oxlint = {},

        terraformls = {},
      }

      -- Ensure the servers and tools above are installed
      --
      -- To check the current status of installed tools and/or manually install
      -- other tools, you can run
      --    :Mason
      --
      -- You can press `g?` for help in this menu.

      -- Manual list for Mason. The server keys from `servers` above are appended automatically
      -- below, except the ones whose Mason package name differs (see `lsp_name_exceptions`).
      local ensure_installed = {
        'php-cs-fixer', -- Linter / formatter (php)
        'phpstan', -- static analysis
        'php-debug-adapter', -- DAP
        'marksman', -- markdown LSP
        'dotenv-linter', -- Linter (dotenv)
        -- 'markdownlint-cli2', -- markdown Linter
        -- Mason package names that do not match their nvim-lspconfig server key:
        'lua-language-server',
        'typescript-language-server',
        'astro-language-server',
        'tailwindcss-language-server',
        'css-lsp',
        'html-lsp',
        'yaml-language-server',
        'json-lsp',
        'terraform-ls',
      }

      local lsp_name_exceptions = {
        -- Server keys whose Mason package is not named after the key. Their package is listed in
        -- `ensure_installed` above instead of being derived from the key.
        lua_ls = true, -- mason: lua-language-server
        ts_ls = true, -- mason: typescript-language-server
        astro = true, -- mason: astro-language-server
        tailwindcss = true, -- mason: tailwindcss-language-server
        cssls = true, -- mason: css-lsp
        html = true, -- mason: html-lsp
        yamlls = true, -- mason: yaml-language-server
        jsonls = true, -- mason: json-lsp
        terraformls = true, -- mason: terraform-ls
      }

      for server_name, _ in pairs(servers or {}) do
        if not lsp_name_exceptions[server_name] then table.insert(ensure_installed, server_name) end
      end

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      -- Capabilities advertised to every server. blink.cmp adds snippet support and resolved
      -- completion items on top of Neovim's defaults; the pcall keeps this file loadable when the
      -- completion plugin is unavailable.
      local has_blink, blink = pcall(require, 'blink.cmp')
      local capabilities = has_blink and blink.get_lsp_capabilities() or {}

      -- foldingRange: required by nvim-ufo for LSP-based folding
      vim.lsp.config('*', {
        capabilities = vim.tbl_deep_extend('force', capabilities, {
          textDocument = {
            foldingRange = {
              dynamicRegistration = false,
              lineFoldingOnly = true,
            },
          },
        }),
      })

      for name, server in pairs(servers) do
        vim.lsp.config(name, server)
        vim.lsp.enable(name)
      end
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
