return {
  'nickjvandyke/opencode.nvim',
  version = '*', -- Latest stable release
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      -- Your configuration, if any; goto definition on the type for details
    }

    vim.o.autoread = true -- Required for `vim.g.opencode_opts.events.reload`

    -- Recommended/example keymaps
    vim.keymap.set({ 'n', 'x' }, '<leader>oa', function() require('opencode').ask '@this: ' end, { desc = 'Ask OpenCode…' })
    vim.keymap.set({ 'n', 'x' }, '<leader>os', function() require('opencode').select() end, { desc = 'Select OpenCode…' })

    vim.keymap.set({ 'n', 'x' }, 'go', function() return require('opencode').operator '@this ' end, { desc = 'Append range to OpenCode', expr = true })
    vim.keymap.set('n', 'goo', function() return require('opencode').operator '@this ' .. '_' end, { desc = 'Append line to OpenCode', expr = true })

    vim.keymap.set({ 'n', 't' }, '<A-u>', function() require('opencode').command 'session.half.page.up' end, { desc = 'Scroll OpenCode up' })
    vim.keymap.set({ 'n', 't' }, '<A-d>', function() require('opencode').command 'session.half.page.down' end, { desc = 'Scroll OpenCode down' })

    -- Send current buffer
    vim.keymap.set('n', '<leader>ob', function()
      local loc = require('opencode').format { buf = 0 }
      require('opencode').prompt(loc .. ': ')
    end, { desc = 'Send buffer to OpenCode' })

    -- Pick and send a file
    vim.keymap.set('n', '<leader>of', function()
      require('snacks').picker.files {
        on_select = function(item)
          local loc = require('opencode').format { path = item.file }
          require('opencode').prompt(loc .. ': ')
        end,
      }
    end, { desc = 'Pick file and send to OpenCode' })
  end,
}
