return {
  'phpactor/phpactor',
  build = 'composer install', -- Builds the executable if you do not have it yet
  ft = 'php', -- Only loaded for PHP files
  config = function()
    -- With 'nvim', Phpactor uses vim.ui.select(),
    -- which is what Snacks.picker captures nicely in a vertical layout.
    vim.g.phpactorMenuStrategy = 'nvim'
    -- For the inputs (such as the path when moving classes)
    vim.g.phpactorInputHandlerStrategy = 'nvim'
  end,
}
