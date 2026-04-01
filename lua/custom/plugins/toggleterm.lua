return {
  'akinsho/toggleterm.nvim',
  version = "*",
  config = function()
    require("toggleterm").setup({
      size = 15,
      open_mapping = [[<C-t>]],
      -- hide_numbers = true,
      -- shade_terminals = true,
      -- shading_factor = 2,
      -- start_in_insert = true,
      -- insert_mappings = true,
      -- persist_size = true,
      direction = 'horizontal', -- 'float' | 'horizontal' | 'vertical'
      close_on_exit = false,
      shell = vim.o.shell,
    })
  end
}
