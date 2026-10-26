return {
  {
    'carderne/pi-nvim',
    config = function()
      require('pi-nvim').setup {
        command = 'gentle-shell',
        split = 'vertical',
        socket_path = nil, -- Auto-discovers the sockets in /tmp
        set_default_keymaps = false, -- Defaults disabled so we can map them our way
      }

      local map = vim.keymap.set

      map({ 'n', 'v' }, '<leader>po', ':Pi<CR>', { desc = 'Pi: [O]pen Pi' })
      map({ 'n', 'v' }, '<leader>pp', ':PiSend<CR>', { desc = 'Pi: Send interactive Dialog' })
      map('n', '<leader>pb', ':PiSendBuffer<CR>', { desc = 'Pi: Send [B]uffer' })
      map('n', '<leader>pf', ':PiSendFile<CR>', { desc = 'Pi: Send [F]ile' })
      map('v', '<leader>ps', ':PiSendSelection<CR>', { desc = 'Pi: Send [S]election' })
      map('n', '<leader>pt', ':PiPing<CR>', { desc = 'Pi: Verify connection (Ping)' })
      map('n', '<leader>pl', ':PiSessions<CR>', { desc = 'Pi: [L]ist sessions' })
    end,
  },
}
