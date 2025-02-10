
-- Set scrolloff
vim.o.scrolloff = 40

vim.opt.clipboard:append("unnamedplus")

-- Define leader key
vim.g.mapleader = " "
-- Keybindings
local function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then options = vim.tbl_extend("force", options, opts) end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end


-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

  -- "dial.nvim",
  -- "flit.nvim",
  -- "lazy.nvim",
  -- "leap.nvim",
  -- "mini.ai",
  -- "mini.comment",
  -- "mini.move",
  -- "mini.pairs",
  -- "mini.surround",
  -- "nvim-treesitter",
  -- "nvim-treesitter-textobjects",
  -- "nvim-ts-context-commentstring",
  -- "vim-repeat",
  -- "yanky.nvim",
require("lazy").setup({

  {
    "chrisgrieser/nvim-spider",
    keys = {
      {
        "e",
        "<cmd>lua require('spider').motion('e')<CR>",
        mode = { "n", "o", "x" },
      },
      {
        "b",
        "<cmd>lua require('spider').motion('b')<CR>",
        mode = { "n", "o", "x" },
      },
      {
        "w",
        "<cmd>lua require('spider').motion('w')<CR>",
        mode = { "n", "o", "x" },
      },
    },
  },
  {  "gbprod/yanky.nvim" },


})

-- Debug, Rename, Stop, Toggle Distraction Free Mode
map("n", "<leader>d", "<Cmd>call VSCodeNotify('workbench.action.debug.start')<CR>")
map("n", "<leader>r", "<Cmd>call VSCodeNotify('editor.action.rename')<CR>")
map("n", "<leader>z", "<Cmd>call VSCodeNotify('workbench.action.toggleZenMode')<CR>")

-- Terminal, Format, Find
map("n", "<leader>t", "<Cmd>call VSCodeNotify('workbench.action.terminal.toggleTerminal')<CR>")
map("n", "<leader>l", "<Cmd>call VSCodeNotify('editor.action.formatDocument')<CR>")
map("n", "/", "<Cmd>call VSCodeNotify('actions.find')<CR>")

-- Run
map("n", "<leader>rr", "<Cmd>call VSCodeNotify('workbench.action.debug.run')<CR>")

-- Go to next error
map("n", "<S-Space>", "<Cmd>call VSCodeNotify('editor.action.marker.next')<CR>")

-- Manage recent projects
map("n", "<leader>p", "<Cmd>call VSCodeNotify('workbench.action.openRecent')<CR>")

-- Window navigation (Note: These might conflict with VSCode's own keybindings)
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Search settings
vim.o.incsearch = true

-- Go to action, file, declaration
map("n", "<leader>a", "<Cmd>call VSCodeNotify('workbench.action.showCommands')<CR>")
map("n", "f", "<Cmd>call VSCodeNotify('workbench.action.quickOpen')<CR>")
map("n", "<leader>d", "<Cmd>call VSCodeNotify('editor.action.revealDefinition')<CR>")

-- Back and forward
map("n", "gb", "<Cmd>call VSCodeNotify('workbench.action.navigateBack')<CR>")
map("n", "gf", "<Cmd>call VSCodeNotify('workbench.action.navigateForward')<CR>")

-- Indent/outdent visual selection
map("n", "<leader>[", "<Cmd>call VSCodeNotify('editor.action.outdentLines')<CR>")
map("n", "<leader>]", "<Cmd>call VSCodeNotify('editor.action.indentLines')<CR>")

-- Insert at beginning of line (similar to your `<leader>i ~hi`)
map("n", "<leader>i", "^i")

-- CURSOR commands 
-- aichat.focuschatpaneaction
-- "command": "workbench.action.chat.open",

map("n", "<leader>cc", "<Cmd>call VSCodeNotify('aichat.focuschatpaneaction')<CR>")
map("n", "<leader>cn", "<Cmd>call VSCodeNotify('aichat.newchatbuttonaction')<CR>")
map("n", "<leader>cf", "<Cmd>call VSCodeNotify('workbench.action.chat.insertIntoNewFile')<CR>")
