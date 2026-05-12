-- return {
-- 	{
-- 		'nvim-lualine/lualine.nvim',
-- 		dependencies = { 'nvim-tree/nvim-web-devicons' },
-- 		config = function ()
-- 			require('lualine').setup {
-- 				options = {
-- 					theme = 'tomorrow_night'
-- 				}
-- 			}
-- 		end,
-- 	}
-- }
return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local function show_macro_recording()
        local recording_register = vim.fn.reg_recording()
        if recording_register == '' then
          return ''
        else
          return '󰑋  Recording @' .. recording_register
        end
      end

      require('lualine').setup {
        options = {
          theme = 'tomorrow_night',
          globalstatus = true,
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = {
            'branch',
            'diff',
            'diagnostics',
            {
              show_macro_recording,
              color = { fg = '#ff9e64', gui = 'bold' },
            },
          },
        },
      }

      -- Autocommands to instantly refresh Lualine
      vim.api.nvim_create_autocmd('RecordingEnter', {
        callback = function()
          require('lualine').refresh {
            place = { 'statusline' },
          }
        end,
      })

      vim.api.nvim_create_autocmd('RecordingLeave', {
        callback = function()
          local timer = vim.loop.new_timer()
          if timer then
            timer:start(
              50,
              0,
              vim.schedule_wrap(
                function()
                  require('lualine').refresh {
                    place = { 'statusline' },
                  }
                end
              )
            )
          end
        end,
      })
    end,
  },
}
