-- ~/.config/nvim/lua/plugins/fzf-lua.lua
return {
	"ibhagwan/fzf-lua",
	-- optional for icon support
	-- dependencies = { "nvim-tree/nvim-web-devicons" },
	-- or if using mini.icons/mini.nvim
	dependencies = { "echasnovski/mini.icons" },
	opts = {},
	keys = {
		{
			"<leader>ff",
			function()
				require("fzf-lua").files()
			end,
			desc = "[f]ind [f]iles in project directory",
		},
		{
			"<leader>fg",
			function()
				require("fzf-lua").live_grep()
			end,
			desc = "[f]ind by [g]repping in project directory",
		},
		{
			"<leader>fc",
			function()
				require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
			end,
			desc = "[f]ind in neovim [c]onfiguration",
		},
		{
			"<leader>fh",
			function()
				require("fzf-lua").helptags()
			end,
			desc = "[f]ind [h]elp",
		},
		{
			"<leader>fk",
			function()
				require("fzf-lua").keymaps()
			end,
			desc = "[f]ind [k]eymaps",
		},
		{
			"<leader>fb",
			function()
				require("fzf-lua").builtin()
			end,
			desc = "[f]ind [b]uiltin FZF",
		},
		{ -- busca la palabra simple
			"<leader>fw",
			function()
				require("fzf-lua").grep_cword()
			end,
			desc = "[f]ind current [w]ord",
		},
		{ -- busca la palabra incluyendo símbolos especiales
			"<leader>fW",
			function()
				require("fzf-lua").grep_cWORD()
			end,
			desc = "[f]ind current [W]ORD",
		},
		{
			"<leader>fd",
			function()
				require("fzf-lua").diagnostics_document()
			end,
			desc = "[f]ind [d]iagnostics",
		},
		{
			"<leader>fr",
			function()
				require("fzf-lua").resume()
			end,
			desc = "[f]ind [r]esume",
		},
		{
			"<leader>fo",
			function()
				require("fzf-lua").oldfiles()
			end,
			desc = "[f]ind [o]ld Files",
		},
		{ -- Si tienes muchos archivos abiertos, este comando te permite saltar entre ellos. Es mucho más rápido que usar pestañas.
			"<leader><leader>",
			function()
				require("fzf-lua").buffers()
			end,
			desc = "[\\] Find existing buffers",
		},
		{ -- Busca texto pero solo dentro del archivo que tienes abierto en ese momento
			"<leader>/",
			function()
				require("fzf-lua").lgrep_curbuf()
			end,
			desc = "[/] Live grep the current buffer",
		},
		{
			"<leader>fm",
			function()
				require("fzf-lua").commands()
			end,
			desc = "[f]ind co[m]mands",
		},
	},
}
