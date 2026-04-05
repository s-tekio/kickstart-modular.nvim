return {
  'phpactor/phpactor',
  build = 'composer install', -- Esto compila el ejecutable si no lo tienes
  ft = 'php', -- Solo se carga para archivos PHP
  config = function()
    -- Al poner 'nvim', Phpactor usará vim.ui.select()
    -- que es lo que Snacks.picker captura perfectamente en vertical.
    vim.g.phpactorMenuStrategy = 'nvim'
    -- Para los inputs (como la ruta al mover clases)
    vim.g.phpactorInputHandlerStrategy = 'nvim'
  end,
}
