-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`
local map = vim.keymap.set

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic Config & Keymaps
-- See :help vim.diagnostic.Opts
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  -- Can switch between these as you prefer
  virtual_text = true, -- Text shows up at the end of the line
  virtual_lines = false, -- Text shows up underneath the line, with virtual lines

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = { float = true },
}

map('n', ',q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
-- map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
-- Workaround mapping for edge cases (like Claude Code: when pressing Esc while thinking, it stops the process)
map('t', '<S-Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- map('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- map('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- map('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- map('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Window resize (Vertical)
map('n', '<M-Up>', ':resize +2<CR>', { desc = 'Increase window height' })
map('n', '<M-Down>', ':resize -2<CR>', { desc = 'Decrease window height' })

-- Window resize (Horizontal)
map('n', '<M-Left>', ':vertical resize -2<CR>', { desc = 'Decrease window width' })
map('n', '<M-Right>', ':vertical resize +2<CR>', { desc = 'Increase window width' })
-- map('n', 'H', ':tabprevious<CR>', { desc = 'Previous tab' })
-- map('n', 'L', ':tabnext<CR>', { desc = 'Next tab' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- map("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- map("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- map("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- map("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- vim: ts=2 sts=2 sw=2 et

map('i', 'jk', '<Esc>', { desc = 'Returns to normal mode' })

map({ 'n', 'v', 'x' }, '<leader>p', [["_dP]], { desc = 'Pastes from the global clipboard and prevents selection to be yanked' })
map('n', 'x', '"_x', { desc = 'Delete under cursor and prevents to be yanked' })
map({ 'n', 'v' }, '<leader>D', '"_d', { desc = 'Deletes text under cursor/selection and prevents selection to be yanked' })

-- <leader>q is defined in bufferline
-- map('n', '<leader>q', ':q<CR>', { desc = 'Closes the current window' })
map('n', '<leader>Q', ':qa<CR>', { desc = 'Closes all windows' })
map('n', '<M-v>', '<C-W>v<C-W>l', { desc = 'Opens and places cursor in a new vertical window' })
map('n', '<M-t>', ':tabnew<CR>', { desc = 'Opens new tab' })

map('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Moves selected lines down' })
map('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Moves selected lines up' })
map('n', 'J', 'mzJ`z', { desc = 'Joins lines and keeps the cursor in the same place' })

map('n', '<C-d>', '<C-d>zz', { desc = 'Jumps down and keeps the cursor in the same place' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Jumps up and keeps the cursor in the same place' })
map('n', 'n', 'nzzzv', { desc = 'Goes to the next result on the search and keeps the cursor in the middle of the screen' })
map('n', 'N', 'Nzzzv', { desc = 'Goes to the previous result on the search and keeps the cursor in the middle of the screen' })

-- map('c', 'W', 'w')

map('n', 'Q', '<nop>')
