_G.get_git_root = function()
  local dot_git = vim.fs.find('.git', {
    upward = true,
    path = vim.api.nvim_buf_get_name(0),
  })[1]

  if dot_git then return vim.fs.dirname(dot_git) end
  return vim.uv.cwd()
end
