return {
  {
    'carderne/pi-nvim',
    config = function()
      require('pi-nvim').setup {
        command = 'gentle-shell',
        split = 'vertical',
        socket_path = nil, -- Auto-descubre los sockets en /tmp automáticamente
        set_default_keymaps = false, -- Desactivamos los nativos para configurarlos a nuestro gusto
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
