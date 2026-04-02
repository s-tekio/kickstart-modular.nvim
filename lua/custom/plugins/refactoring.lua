return {
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    lazy = false,
    opts = {},
		config = function ()
			vim.keymap.set(
				{ "n", "x" },
				"<leader>rmm",
				function() return require('refactoring').refactor('Extract Function') end,
				{ desc = '[R]efactor extract [M]ethod', expr = true }
			)
			vim.keymap.set(
				{ "n", "x" },
				"<leader>rmf",
				function() return require('refactoring').refactor('Extract Function To File') end,
				{ desc = '[R]efactor [M]ethod to [F]ile', expr = true }
			)
			vim.keymap.set(
				{ "n", "x" },
				"<leader>rv",
				function() return require('refactoring').refactor('Extract Variable') end,
				{ desc = '[R]efactor extract [V]ariable', expr = true }
			)
			vim.keymap.set(
				{ "n", "x" },
				"<leader>rI",
				function() return require('refactoring').refactor('Inline Function') end,
				{ desc = '[R]efactor [I]nline function', expr = true }
			)
			vim.keymap.set(
				{ "n", "x" },
				"<leader>ri",
				function() return require('refactoring').refactor('Inline Variable') end,
				{ desc = '[R]efactor [I]nline variable', expr = true }
			)

			vim.keymap.set(
				{ "n", "x" },
				"<leader>rbb",
				function() return require('refactoring').refactor('Extract Block') end,
				{ desc = '[R]efactor extract [B]lock', expr = true }
			)
			vim.keymap.set(
				{ "n", "x" },
				"<leader>rbf", function() return require('refactoring').refactor('Extract Block To File') end,
				{ desc = '[R]efactor [B]lock to [F]ile', expr = true }
			)

			vim.keymap.set(
				{"n", "x"},
				"<leader>rr",
				function() require('refactoring').select_refactor() end,
				{ desc = '[R]efactoring' }
			)
		end,
  },
}
