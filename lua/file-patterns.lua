vim.filetype.add {
	-- NOTE: the 3 extension, filename and pattern are configured for a performance reason.
	-- Neovim follows this order to look for the match. REGEX can be "expensive" in performance,
	-- so it's better to use it as a 'fallback' option
  extension = {
    env = 'sh', -- :TSInstall bash if 'sh' isn't working by default
  },
  filename = {
    ['.env'] = 'sh',
    ['.env.local'] = 'sh',
    ['.env.test'] = 'sh',
    ['.env.dist'] = 'sh',
  },
  pattern = {
    -- This captures files like .env.development.local
    ['%.env%.[%w_.-]+'] = 'sh',
  },
}
