-- ~/.config/nvim/lua/config/autocmds.lua

local autocmd = vim.api.nvim_create_autocmd

-- Resaltar texto al copiar (Yank)
autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch", -- El color que se va a ver
			timeout = 150, -- Cuánto dura el resaltado (ms)
		})
	end,
})

autocmd("BufWritePre", {
	desc = "Limpiar espacios en blanco al final de la línea",
	pattern = { "*.c", "*.cpp", "*.lua", "*.py", "*.sh", "*.tex" },
	callback = function()
		local save_cursor = vim.api.nvim_win_get_cursor(0)
		vim.cmd([[%s/\s\+$//e]])
		vim.api.nvim_win_set_cursor(0, save_cursor)
	end,
})

