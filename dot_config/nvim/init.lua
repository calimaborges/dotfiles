-- Leader
vim.g.mapleader = " "      -- set before any <leader> mapping
vim.g.maplocalleader = " "

local option = vim.opt

-- Appearance
option.number = true         -- absolute number on current line
option.relativenumber = true -- relative numbers elsewhere
option.cursorline = true     -- highlight current line
option.signcolumn = "yes"    -- avoid text shifting when signs appear
option.scrolloff = 8         -- context lines around cursor
option.wrap = false          -- scroll sideways instead of wrapping
option.termguicolors = true  -- 24-bit colors

-- Indentation
option.expandtab = true   -- spaces instead of tabs
option.tabstop = 4        -- tab display width
option.shiftwidth = 4     -- indent width
option.smartindent = true -- auto-indent new lines

-- Search
option.ignorecase = true -- case-insensitive...
option.smartcase = true  -- ...unless pattern has a capital
option.incsearch = true  -- match while typing
option.hlsearch = true   -- keep matches highlighted

-- Windows
option.splitright = true -- vertical splits open right
option.splitbelow = true -- horizontal splits open below

-- Diff
option.diffopt:remove("inline:char") -- default highlights changes per character
option.diffopt:append("inline:word") -- highlight changes per word instead

-- Editing
option.mouse = "a"               -- mouse in all modes
option.clipboard = "unnamedplus" -- use system clipboard
option.undofile = true           -- persist undo history
option.swapfile = false          -- no swap files
option.updatetime = 250          -- faster CursorHold (default 4000)
option.timeoutlen = 400          -- mapping timeout (default 1000)
option.foldlevelstart = 99       -- open files with all folds expanded

-- Plugins
vim.api.nvim_create_autocmd("PackChanged", { -- rebuild parsers when nvim-treesitter updates
	callback = function(event)
		local plugin = event.data
		if plugin.spec.name == "nvim-treesitter" and plugin.kind == "update" then
			if not plugin.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			vim.cmd("TSUpdate")
		end
	end,
})

vim.pack.add({
	"https://github.com/tpope/vim-fugitive", -- git integration
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" }, -- parser manager
	"https://github.com/folke/which-key.nvim", -- key hints popup
}, { confirm = false }) -- install without prompting

vim.cmd.packadd("nvim.undotree") -- built-in undo tree viewer

require("which-key").setup({
	icons = { mappings = false },
	spec = {
		{ "<leader>g", group = "git" },
	},
})

-- Treesitter
require("nvim-treesitter").install({ -- no-op for parsers already installed
	"python",
	"typescript",
	"bash",
	"json",
	"yaml",
	"rust",
	"html",
	"css",
	"javascript",
	"tsx",
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function(event)
		if not pcall(vim.treesitter.start, event.buf) then -- fails when no parser exists
			return
		end
		vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		vim.opt_local.foldmethod = "expr"
		vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
	end,
})

-- Keymaps
local map = vim.keymap.set

map("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "<leader>w", "<Cmd>write<CR>", { desc = "Save" })
map("n", "<leader>q", "<Cmd>quit<CR>", { desc = "Quit" })
map("n", "<leader>e", "<Cmd>Explore<CR>", { desc = "File explorer" })
map("n", "<leader>u", "<Cmd>Undotree<CR>", { desc = "Undo tree" })

map("n", "<leader>gs", "<Cmd>Git<CR>", { desc = "Status (s/u stage, cc commit)" })
map("n", "<leader>gd", "<Cmd>Gvdiffsplit<CR>", { desc = "Diff file vs index" })
map("n", "<leader>gb", "<Cmd>Git blame<CR>", { desc = "Blame file" })
map("n", "<leader>gl", "<Cmd>Git log --oneline<CR>", { desc = "Commit log" })
map("n", "<leader>gp", "<Cmd>Git push<CR>", { desc = "Push" })

map("n", "<C-h>", "<C-w>h", { desc = "Go to left split" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower split" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper split" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right split" })

map("v", "<", "<gv", { desc = "Dedent, keep selection" })
map("v", ">", ">gv", { desc = "Indent, keep selection" })

-- Autocommands
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.hl.on_yank() -- flash yanked text
	end,
})
