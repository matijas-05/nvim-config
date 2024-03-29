-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.highlight.on_yank() end,
  group = highlight_group,
  pattern = "*",
})

-- Replace the quickfix window with Trouble when viewing TSC results
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "quickfix",
  group = vim.api.nvim_create_augroup("ReplaceQuickfixWithTrouble", {}),
  callback = function()
    local title = vim.fn.getqflist({ title = 0 }).title
    if title ~= "TSC" then
      return
    end

    local ok, trouble = pcall(require, "trouble")
    if ok then
      vim.defer_fn(function()
        vim.cmd("cclose")
        trouble.open("quickfix")
      end, 0)
    end
  end,
})
