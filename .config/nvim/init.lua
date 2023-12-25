-- Remap leader key to `,`
vim.g.mapleader = ","
-- Visual size of hard tabs
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
-- Display line numbers in gutter
vim.opt.number = true
-- Use GUI colors also in terminal
if vim.fn.has("termguicolors") then
	vim.opt.termguicolors = true
end
--
vim.opt.completeopt = "menu,menuone,noselect"
-- Persistent undo
vim.opt.undofile = true

local vts = {
  [vim.diagnostic.severity.ERROR] = { ctermfg = 1, guifg = "Red", icon = "!" };                     
  [vim.diagnostic.severity.WARN] = { ctermfg = 3, guifg = "Orange", icon = "?" };
  [vim.diagnostic.severity.INFO] = { ctermfg = 4, guifg = "LightBlue", icon = "i" };
  [vim.diagnostic.severity.HINT] = { ctermfg = 7, guifg = "LightGrey", icon = "h" };
}

vim.diagnostic._get_virt_text_chunks = function(line_diags, opts)
	if #line_diags == 0 then
		return nil
	end

	opts = opts or {}
	local spacing = opts.spacing or 4

	local aggs = {}
	local result = {}
	for i = 1, #line_diags do
		local hl = vts[line_diags[i].severity].icon
		local v = aggs[hl] or table.insert(result, {hl = hl, n = 0}) or result[#result]
		v.n, aggs[hl] = v.n + 1, v
	end
	local r2 = {}
	for i = 1, #result do
		local v = result[i]
		table.insert(r2, string.format("%s %d", v.hl, v.n))
	end
	vim.pretty_print(r2)

	return {{string.rep(" ", spacing)},{ table.concat(r2, " "), "DiagnosticVirtualTextError" }}
end

vim.diagnostic.config({
	signs = false,
	severity_sort = true,
-- 	virtual_text = function(a, b, c)
-- 	end
-- 	virtual_text = {
-- 		format = function(diagnostic)
-- 			return diagnostic.message
-- 		end
-- 	},
})

-- vim.opt.signcolumn="number"

-- vim.cmd [[
--   highlight! DiagnosticLineNrError guibg=#51202A guifg=#FF0000 gui=bold
--   highlight! DiagnosticLineNrWarn guibg=#51412A guifg=#FFA500 gui=bold
--   highlight! DiagnosticLineNrInfo guibg=#1E535D guifg=#00FFFF gui=bold
--   highlight! DiagnosticLineNrHint guibg=#1E205D guifg=#0000FF gui=bold
-- 
--   sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=DiagnosticLineNrError
--   sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn linehl= numhl=DiagnosticLineNrWarn
--   sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo linehl= numhl=DiagnosticLineNrInfo
--   sign define DiagnosticSignHint text= texthl=DiagnosticSignHint linehl= numhl=DiagnosticLineNrHint
-- ]]

-- Load plugins
-- START Changes require :PackerCompile
require("packer").startup(function(use)
	use "wbthomason/packer.nvim" -- Plugins manager itself
	use "neovim/nvim-lspconfig" -- Common configurations for LSPs
	use "lukas-reineke/lsp-format.nvim" -- Autoformatting using lSPs
	use {
		"nvim-treesitter/nvim-treesitter",
		run = function()
			require("nvim-treesitter.install").update({ with_sync = true })()
		end,
	}
	use "JoosepAlviste/nvim-ts-context-commentstring"
	use "numToStr/Comment.nvim" -- Comments toggling
	use "L3MON4D3/LuaSnip" -- snippets engine
	use "hrsh7th/nvim-cmp" -- autocompletion
	use "hrsh7th/cmp-nvim-lsp" -- LSP support for nvim-cmp
	use "saadparwaiz1/cmp_luasnip" -- nvim-cmp <-> LuaSnip integration
	use { -- Formatting using non-LSP tools
		"jose-elias-alvarez/null-ls.nvim",
		requires = { "nvim-lua/plenary.nvim" },
	}
	-- use "farmergreg/vim-lastplace"
	use "ethanholz/nvim-lastplace" -- restoring line position

	use "savq/melange"
end)
-- END

vim.cmd("colorscheme melange")

require("nvim-lastplace").setup {}

local luasnip = require("luasnip")

local cmp = require("cmp")
cmp.setup {
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert {
		-- NOTE This is for triggering completion manually
		["<C-h>"] = cmp.mapping.complete(),
		["<C-l>"] = cmp.mapping.confirm({ select = true }),
		["<C-j>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
				-- What about "has_words_before"?
			else
				fallback()
			end
		end, { "i", "s" }),
		["<C-k>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	},
	sources = cmp.config.sources {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
	},
	experimental = {
		ghost_text = true,
	},
}
local cmpCaps = require("cmp_nvim_lsp").default_capabilities()

local lsp = require("lspconfig")
local lspFormat = require("lsp-format")

lspFormat.setup {}
lsp.gopls.setup {
	capabilities = cmpCaps,
	init_options = {
		usePlaceholders = true, -- for arguments placeholders
	},
	-- 				cmd = function()
	-- 					print(1)
	-- 				end,
}
lsp.golangci_lint_ls.setup {}
lsp.tsserver.setup {
	capabilities = cmpCaps,
	settings = {
		completions = {
			completeFunctionCalls = true,
		}
	},
}
lsp.eslint.setup {}
local null_ls = require("null-ls")
null_ls.setup {
	sources = {
		null_ls.builtins.formatting.prettier,
		null_ls.builtins.formatting.goimports.with({
			command = "gosimports",
			-- FIXME The local parameter differs between projects
			extra_args = { "-local", "bitbucket.org/bugfender/remote-logger-web" },
		}),
	},
	log_level = "debug",
	on_attach = lspFormat.on_attach,
}
-- Synchronous formatting on :wq
vim.cmd [[cabbrev wq execute "Format sync" <bar> wq]]

require("nvim-treesitter.configs").setup {
	ensure_installed = { "tsx", "typescript" },
	context_commentstring = {
		enable = true,
		enable_autocmd = false,
	},
}

require("Comment").setup {
	pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
	toggler = {
		line = "<leader>cc",
		block = "<leader>bc",
	},
	opleader = {
		line = "<leader>c",
		block = "<leader>b",
	},
}

function luasnip_jump_or_fallback(step, key)
	return function()
		if luasnip.jumpable(step) then
			luasnip.jump(step)
		else
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "nt", false)
		end
	end
end

vim.keymap.set({ "i", "s" }, "<C-j>", luasnip_jump_or_fallback(1, "<C-j>"), { silent = true })
vim.keymap.set({ "i", "s" }, "<C-k>", luasnip_jump_or_fallback(-1, "<C-k>"), { silent = true })
