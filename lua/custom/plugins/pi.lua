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

      map({ 'n', 'v' }, '<leader>po', ':Pi<CR>', { desc = 'Pi: Open Pi' })
      map({ 'n', 'v' }, '<leader>pp', ':PiSend<CR>', { desc = 'Pi: Diálogo interactivo' })
      map('n', '<leader>pb', ':PiSendBuffer<CR>', { desc = 'Pi: Enviar búfer completo' })
      map('n', '<leader>pf', ':PiSendFile<CR>', { desc = 'Pi: Enviar búfer completo' })
      map('v', '<leader>ps', ':PiSendSelection<CR>', { desc = 'Pi: Enviar selección visual' })
      map('n', '<leader>pt', ':PiPing<CR>', { desc = 'Pi: Verificar conexión (Ping)' })
      map('n', '<leader>pl', ':PiSessions<CR>', { desc = 'Pi: Listar/Cambiar sesiones' })
    end,
  },
}
