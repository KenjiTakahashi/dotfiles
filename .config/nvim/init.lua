if vim.g.vscode then -- TODO revisit later
	return
end
-- Remap leader key to `,`
vim.g.mapleader = ","
-- Visual size of hard tabs
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
-- Display line numbers in gutter
vim.opt.number = true
-- Use GUI colors also in terminal, if available
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
	-- vim.pretty_print(r2)

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

-- XXX Experimental, revisit later
-- vim.loader.enable()

require("lazy").setup({
	{ "catppuccin/nvim", name = "catppuccin", lazy = false, priority = 1000 }, -- colorscheme

	"ethanholz/nvim-lastplace", -- restoring line position
	-- "farmergreg/vim-lastplace" -- old (vimscript) version of the above (in case)

	{ "lukas-reineke/lsp-format.nvim", version = "2.6.3" }, -- LSP autoformatting

	{ "neovim/nvim-lspconfig", version = "0.1.7" }, -- LSP configs

	{ "nvim-treesitter/nvim-treesitter", version = "0.9.1", build = ":TSUpdate" },

	{ "numToStr/Comment.nvim", version = "0.8.0", dependencies = { -- Comments toggling
		"JoosepAlviste/nvim-ts-context-commentstring",
	} },

	-- { "ms-jpq/coq_nvim", name = "coq", branch = "coq" },
	-- { "ms-jpq/coq.artifacts", branch = "artifacts" },
	"hrsh7th/nvim-cmp", -- completions
	"hrsh7th/cmp-nvim-lsp", -- LSP source for completions
	{ "L3MON4D3/LuaSnip", version = "2.1.1", dependencies = { -- snippets engine
		"rafamadriz/friendly-snippets", -- snippets database
	} },
	"saadparwaiz1/cmp_luasnip", -- snippets support for completions

	{ "nvimtools/none-ls.nvim", dependencies = {
		"nvim-lua/plenary.nvim",
	} },

	"windwp/nvim-projectconfig",
	{ dir = "~/+projects/_exp/project.nvim" },
	-- "ahmedkhalf/project.nvim" -- XXX Upstream of the above
})

require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"go",
		"tsx",
		"typescript",
	},
})

vim.g.skip_ts_context_commentstring_module = true
require("ts_context_commentstring").setup({
	enable_autocmd = false,
})

require("catppuccin").setup({
	flavour = "macchiato",
	dim_inactive = {
		enabled = true,
	},
	integrations = {
		cmp = true,
	},
})
vim.cmd.colorscheme("catppuccin")

require("nvim-lastplace").setup({})

require("Comment").setup({
	pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
	toggler = {
		line = "<leader>cc",
		block = "<leader>bc",
	},
	opleader = {
		line = "<leader>c",
		block = "<leader>b",
	},
})

local lsp_format = require("lsp-format")
lsp_format.setup({})

local function project_dependent_setup()
	require("nvim-projectconfig").setup({})
	vim.print(kenji_goimports_local)

	local none_ls = require("null-ls")
	none_ls.setup {
		sources = {
			none_ls.builtins.formatting.prettier,
			none_ls.builtins.formatting.goimports.with({
				command = "gosimports",
				extra_args = kenji_goimports_local and { "-local", kenji_goimports_local } or {},
			}),
		},
		log_level = "debug",
		on_attach = lsp_format.on_attach,
	}
end
require("project_nvim").setup({
	silent_chdir = false,
	detection_methods = { "pattern" },
	patterns = { ".git" },
	post_hook = project_dependent_setup,
})

local luasnip = require("luasnip")
-- XXX Hack for undoing snippet insertion
-- See https://github.com/L3MON4D3/LuaSnip/issues/830
-- See https://github.com/L3MON4D3/LuaSnip/issues/797
local luasnip_snip_expand = luasnip.snip_expand
luasnip.snip_expand = function(...)
	vim.o.undolevels = vim.o.undolevels
	luasnip_snip_expand(...)
end
require("luasnip.loaders.from_vscode").lazy_load()

local cmp = require("cmp")
cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-h>"] = cmp.mapping(function()
			if cmp.visible() then
				cmp.abort()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			elseif luasnip.in_snippet() then
				vim.cmd.undo()
				luasnip.unlink_current() -- XXX Is this the right function? [Seems to work]
			else
				cmp.complete()
			end
		end, { "i", "s" }),
		["<C-l>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.confirm() -- XXX Use select = true or not?
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		-- XXX Any way to makes these circular?
		["<C-j>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<C-k>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
	}),
	-- TODO Do this better (use lspkind?)
	-- For now just want to know where suggestions come from
	formatting = {
		format = function(entry, vim_item)
			vim_item.menu = ({
				buffer = "[Buffer]",
				nvim_lsp = "[LSP]",
				luasnip = "[LuaSnip]",
				nvim_lua = "[Lua]",
				latex_symbols = "[LaTeX]",
			})[entry.source.name]
			return vim_item
		end
	},
	experimental = {
		ghost_text = true,
	},
})

local cmp_caps = require("cmp_nvim_lsp").default_capabilities()

local lsp = require("lspconfig")

lsp.gopls.setup({
	capabilities = cmp_caps,
	init_options = {
		usePlaceholders = true, -- for arguments placeholders
	},
	-- 				cmd = function()
	-- 					print(1)
	-- 				end,
})
lsp.golangci_lint_ls.setup({})
lsp.tsserver.setup({
	capabilities = cmp_caps,
	settings = {
		completions = {
			completeFunctionCalls = true,
		},
	},
})
lsp.eslint.setup({})
-- local coq = require("coq")
-- lsp.gopls.setup(coq.lsp_ensure_capabilities({
-- 	init_options = {
-- 		usePlaceholders = true,
-- 	},
-- }))

-- Synchronous formatting on :wq
vim.cmd [[cabbrev wq execute "Format sync" <bar> wq]]
