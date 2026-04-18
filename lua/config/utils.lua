-- ~/.config/nvim/lua/config/utils.lua
local M = {}

-- funcion que ejecuta el codigo actual en una ventana dedicada
M.run_code = function()
	vim.cmd("silent! write")

	-- Detectar tipo de archivo
	local filetype = vim.bo.filetype
	local filename = vim.fn.expand("%:p")
	local cmd = ""

	-- Lógica de detección
	if filetype == "python" then
		local venv_python = vim.fn.getcwd() .. "/.venv/bin/python"
		local python_exe = vim.fn.executable(venv_python) == 1 and venv_python or "python3"
		cmd = string.format("%s '%s'", python_exe, filename)
	elseif filetype == "c" then
		-- Compila y ejecuta: genera un binario temporal y lo corre
		local output = "/tmp/" .. vim.fn.expand("%:t:r")
		cmd = string.format("gcc '%s' -o %s && %s", filename, output, output)
	elseif filetype == "cpp" then
		-- Compilación C++ con estándar moderno y advertencias
		local output = "/tmp/" .. vim.fn.expand("%:t:r")
		cmd = string.format("g++ -O2 '%s' -o %s && %s", filename, output, output)
	elseif filetype == "java" then
		-- Java: Compila y luego ejecuta la Clase (asume que el archivo tiene el nombre de la clase)
		local class_name = vim.fn.expand("%:t:r")
		local dir = vim.fn.expand("%:p:h")
		-- Compila en el directorio actual y ejecuta
		cmd = string.format("javac '%s' && java -cp '%s' %s", filename, dir, class_name)
	else
		print("Lenguaje no configurado para ejecución automática.")
		return
	end

	-- Ejecución en ventana dedicada
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].buftype == "terminal" then
			vim.api.nvim_win_close(win, true)
		end
	end

	-- Abrimos el split abajo
	vim.cmd("botright 10split")

	-- Ejecutamos la terminal usando el comando de Neovim directamente
	-- Usamos 'term' seguido del comando. Esto NO está deprecated y es muy estable.
	local shell_cmd = cmd .. "; echo -e '\\n[Proceso terminado]'; read"

	-- Ejecutamos mediante la API de comandos para evitar conflictos de tipos
	vim.cmd("terminal " .. shell_cmd)

	-- 4. Entrar en modo inserto para que el 'read' capture el Enter
	vim.cmd("startinsert")
end

-- funcion que genera un preview pdf temporal usando pandoc y pdflatex, llamada desde keymaps.lua
function M.pandoc_pdf_preview()
	vim.cmd("silent write")

	local input = vim.fn.expand("%")
	local output = "/tmp/" .. vim.fn.expand("%:t:r") .. ".pdf"
	local cmd = string.format("pandoc %s -o %s --pdf-engine=pdflatex", input, output)

	local error_output = {}

	print("Compilando...")

	vim.fn.jobstart(cmd, {
		-- Capturamos los errores línea por línea
		on_stderr = function(_, data)
			if data then
				for _, line in ipairs(data) do
					if line ~= "" then
						table.insert(error_output, line)
					end
				end
			end
		end,
		on_exit = function(_, code)
			if code == 0 then
				vim.fn.jobstart("zathura " .. output, { detach = true })
				print("✔ PDF generado en " .. output)
			else
				print("✖ Error en la compilación")
				if #error_output > 0 then
					-- 1. Unimos TODO el error en un solo string largo
					local raw_error = table.concat(error_output, " ")

					-- 2. Limpieza agresiva de saltos de línea y espacios múltiples
					local clean_error = raw_error:gsub("%s+", " "):gsub("^%s+", "")

					vim.cmd("botright 10new")
					local buf = vim.api.nvim_get_current_buf()

					-- 3. Lo insertamos como UNA SOLA LÍNEA (metida en una tabla)
					vim.api.nvim_buf_set_lines(buf, 0, -1, false, { clean_error })

					-- 4. Forzamos el ajuste de línea (Wrap)
					vim.opt_local.wrap = true
					vim.opt_local.linebreak = true -- Corta por palabras, no por letras

					-- Estética
					vim.opt_local.buftype = "nofile"
					vim.opt_local.bufhidden = "wipe"
					vim.opt_local.swapfile = false
					vim.opt_local.filetype = "bash"
					vim.api.nvim_buf_set_name(buf, "Pandoc Errors")
					-- ... después de set_lines ...
					vim.opt_local.cursorline = true -- Resalta la línea para que no se te pierda la vista
					vim.opt_local.spell = false -- Desactiva el corrector ortográfico en los errores
					-- Color rosado/rojo de "Warning" real
					vim.cmd("highlight PandocErrorGuibg guibg=#2d1b22")
					vim.cmd("setlocal winhighlight=Normal:PandocErrorGuibg")

					-- Atajo para cerrar con 'q'
					vim.keymap.set("n", "q", ":q<CR>", { buffer = buf, silent = true })
				end
			end
		end,
	})
end

return M

