return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
  opts = {
    enhanced_diff_hl = true,
    view = {
      default = {
        layout = 'diff2_horizontal',
        disable_diagnostics = false,
      },
      merge_tool = {
        layout = 'diff3_horizontal',
        disable_diagnostics = false,
      },
      file_history = {
        layout = 'diff2_horizontal',
        disable_diagnostics = false,
      },
    },
  },
  keys = {
    {
      '<leader>gd',
      function()
        local locals = vim.fn.systemlist [[git branch --format="%(refname:short)"]]
        local remotes = vim.fn.systemlist [[git branch -r --format="%(refname:short)"]]

        local choices = {}

        table.insert(choices, { name = '--- LOCAL BRANCHES ---', is_header = true })
        for _, name in ipairs(locals) do
          table.insert(choices, { name = name, icon = '', group = 'local' })
        end

        table.insert(choices, { name = '--- REMOTE BRANCHES ---', is_header = true })
        for _, name in ipairs(remotes) do
          if not name:find 'HEAD' then table.insert(choices, { name = name, icon = '󱓞', group = 'remote' }) end
        end

        vim.ui.select(choices, {
          prompt = 'Diffview: Select branch to compare',
          format_item = function(item)
            if item.is_header then return item.name end
            return string.format('%s %s (%s)', item.icon, item.name, item.group)
          end,
        }, function(choice)
          if not choice or choice.is_header then return end

          vim.cmd('DiffviewOpen ' .. choice.name)
        end)
      end,
      desc = 'Git: Diffview against branch',
    },
    { '<leader>gD', '<cmd>DiffviewOpen<cr>', desc = 'Git: Diffview working tree' },
    { '<leader>gC', '<cmd>DiffviewClose<cr>', desc = 'Git: Diffview Close' },
    { '<leader>gf', '<cmd>DiffviewFileHistory %<cr>', desc = 'Git: Diffview [F]ile History' },
  },
}
