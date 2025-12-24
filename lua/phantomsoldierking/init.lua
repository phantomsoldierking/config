-- Basic config (no Lazy dependency)
require("phantomsoldierking.set")
require("phantomsoldierking.remap")

-- =========================================
-- Bootstrap lazy.nvim FIRST
-- =========================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- =========================================
-- Load plugins
-- =========================================
require("lazy").setup({
  spec = "phantomsoldierking.lazy",
  change_detection = { notify = false },
})

-- =========================================
-- Everything below is independent of Lazy
-- =========================================

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local phantomsoldierkingGroup = augroup("phantomsoldierking", {})
local yank_group = augroup("HighlightYank", {})

function R(name)
  require("plenary.reload").reload_module(name)
end

vim.filetype.add({
  extension = {
    templ = "templ",
  },
})

autocmd("TextYankPost", {
  group = yank_group,
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 40,
    })
  end,
})

autocmd("BufWritePre", {
  group = phantomsoldierkingGroup,
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

autocmd("BufEnter", {
  group = phantomsoldierkingGroup,
  callback = function()
    if vim.bo.filetype == "zig" then
      pcall(vim.cmd.colorscheme, "tokyonight-night")
    else
      pcall(vim.cmd.colorscheme, "rose-pine-moon")
    end
  end,
})

autocmd("LspAttach", {
  group = phantomsoldierkingGroup,
  callback = function(e)
    local opts = { buffer = e.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
    vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
    vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
  end,
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
