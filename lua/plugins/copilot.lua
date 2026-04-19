-- ~/.config/nvim/lua/plugins/copilot.lua
-- habilitar con `<leader>ce`, aumentará 1G ram. Luego de deshabilitar `<leader>ce`, ram disminuye 1G.
return {
	{
		"zbirenbaum/copilot.lua",
		-- Usamos cmd y keys para que NO se cargue al iniciar Neovim
		cmd = "Copilot",
		keys = {
			-- Al presionar cualquiera de estos, se cargará este plugin Y el de abajo
			{ "<leader>ce", "<cmd>Copilot enable<CR>", desc = "[c]opilot [e]nable" },
			{ "<leader>cd", "<cmd>Copilot disable<CR>", desc = "[c]opilot [d]isable" },
			{ "<leader>cs", "<cmd>Copilot status<CR>", desc = "[c]opilot [s]tatus" },
		},
		config = function()
			require("copilot").setup({
				suggestion = {
					enabled = true, -- Si vas a usar copilot-cmp, desactiva las sugerencias nativas para que no se solapen (ghost text vs menú de cmp)
					auto_trigger = true, -- CRÍTICO: No sugerir nada hasta que presiones un atajo
					hide_during_completion = true, -- Oculta el ghost text si el menú flotante está abierto
					keymap = {
						accept = "<M-l>", -- Alt + l para aceptar la sugerencia de ghost
						accept_word = false, -- aceptar solo la siguiente palabra (en lugar de toda la sugerencia)
						accept_line = false, -- aceptar solo la siguiente línea (en lugar de toda la sugerencia)
						next = "<M-]>", -- siguiente sugerencia (si hay varias)
						prev = "<M-[>", -- sugerencia anterior
						dismiss = "<C-]>", -- descartar la sugerencia actual
					},
				},
				panel = { enabled = false },
				server_opts_override = { trace = "off" }, -- Esto ayuda un poco con el consumo de recursos en CPUs modestas
				-- Si quieres limitar a ciertos filetypes, descomenta este bloque y ajusta a tu gusto. De lo contrario, se activará en TODO (lo cual puede ser pesado en archivos grandes o con sintaxis compleja). gitcopilot detecta tu workspace y no se activa en repositorios sin código, y parece que esta activo en todos los archivos del workspace, incluso los que no son de código, pero no consume recursos en archivos sin código, así que no es un gran problema. De todas formas, si quieres limitarlo a ciertos filetypes, puedes hacerlo aquí.
				-- filetypes = {
				-- 	["*"] = false, -- Desactiva TODO por defecto
				-- 	python = true, -- Solo permite en lo que vos quieras
				-- 	lua = true,
				-- 	c = true,
				-- 	markdown = true,
				-- 	latex = true, -- Si usas archivos .tex directamente, activalo aquí
				-- 	tex = true, -- (A veces el filetype es 'tex' en lugar de 'latex')
				-- 	help = false, -- No sugerir en manuales de ayuda
				-- 	gitcommit = true, -- Opcional: a veces es mejor escribir tus propios mensajes de commit
				-- 	gitrebase = false,
				-- 	hgcommit = false,
				-- 	cvs = false,
				-- 	["."] = false, -- No activar en archivos sin extensión (evita carga innecesaria)
				-- },
			})
		end,
	},
	{
		"zbirenbaum/copilot-cmp", -- Complemento para integrar Copilot con nvim-cmp
		-- MAGIA: Solo se carga después de que copilot.lua se haya cargado
		-- pero no tiene disparadores propios (ni cmd ni event)
		lazy = true, -- No se carga automáticamente, solo cuando se le indique
		dependencies = { "zbirenbaum/copilot.lua" }, -- Asegura que se cargue después de copilot.lua
		config = function()
			require("copilot_cmp").setup() -- Configuración mínima, puedes personalizarla como quieras
		end,
		-- Este bloque asegura que se inicialice apenas el plugin base esté listo
		init = function()
			vim.api.nvim_create_autocmd("User", { -- Evento: User (Un evento personalizado, no del sistema).
				pattern = "LazyLoad", -- Patrón: LazyLoad (Se dispara cuando Lazy termina de cargar un plugin).
				callback = function(event)
					if event.data == "copilot.lua" then -- si el evento que se acaba de cargar es `copilot.lua`, entonces
						require("lazy").load({ plugins = { "copilot-cmp" } }) -- carga también el plugin `copilot-cmp`
					end
				end,
			})
		end,
	},
}
-- 		-- En caso de que se cargue el plugin y se habilite Copilot desde que se abre el archivo, este codigo desactiva usando la API interna. De este modo, no aumenta 1G de ram!
-- 		local ok, command = pcall(require, "copilot.command")
-- 		if ok then
-- 			command.disable()
-- 		else
-- 			vim.cmd("Copilot disable")
-- 		end
