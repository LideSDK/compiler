local OS_NAME, EX_NAME, BU_TYPE, INCLUDE, LIBRARIES, LIBNAME

tempfiles = {}

function getParam( arg, nArg, sArg, sParam )
	if ( sArg:sub(1,2) == sParam ) then
		if (#sArg == 2) then
			return arg[nArg+1]
		else
			return sArg:sub(3, #sArg)
		end
	elseif sArg:find(sParam) then
		return sArg:sub(#sParam+1, #sArg)
	end
end

function precompile ( luafile, rootdir, outputdir, input_names)
	local module_name = luafile:sub(1, #luafile - 4)
	os.execute ('precompiler -o "' .. module_name .. '" -l "'..'.'..'\\?.lua" -d "'..outputdir..'" -n '..input_names or module_name)
end

function precompile ( output, rootdir, outputdir, input_names)
	os.execute ('precompiler -o '..output..' -l "'..rootdir..'\\?.lua" -d "'..outputdir..'" -n ' .. input_names)
	table.insert(tempfiles, output..".c")
	table.insert(tempfiles, output..".h")
end

function compile( luafile, outputdir )
	local module_name = luafile:sub(1, #luafile - 4)
	local lib_ext = '.dll'
	os.execute ('gcc -O2 -m32 -c -o '..outputdir.."\\"..module_name..'.o '..outputdir.."\\"..module_name..'.c -I'.. INCLUDE)
	os.execute ('gcc -O -m32 -shared -o '..outputdir.."\\"..module_name..lib_ext..' '..outputdir.."\\"..module_name..'.o -L'..LIBRARIES..' -l'..LIBNAME) -- OJO! PARA LINUX LOS LIBS PODRIAN CAMBIAR
	table.insert(tempfiles, module_name..".o")
end

function compile_lib( module_name, outputdir )
	local lib_ext = '.dll'
	os.execute ('gcc -O2 -m32 -c -o '..outputdir.."\\"..module_name..'.o '..outputdir.."\\"..module_name..'.c -I'.. INCLUDE)
	os.execute ('gcc -O -m32 -shared -o '..outputdir.."\\"..module_name..lib_ext..' '..outputdir.."\\"..module_name..'.o -L'..LIBRARIES..' -l'..LIBNAME) -- OJO! PARA LINUX LOS LIBS PODRIAN CAMBIAR
	table.insert(tempfiles, module_name..".o")
end


for nArg, sArg in pairs(arg) do
	-- Buscamos la opción -p (platform)
	OS_NAME = OS_NAME or getParam(arg, nArg, sArg, '-p')
	-- Buscamos la opción -o (output)
	EX_NAME = EX_NAME or getParam(arg, nArg, sArg, '-o')
	-- Buscamos la opción -i (input)
	LI_NAME = LI_NAME or getParam(arg, nArg, sArg, '-i')
	-- Buscamos la opción -d (directory)
	DI_NAME = DI_NAME or getParam(arg, nArg, sArg, '-d')
	-- Buscamos la opción --noclean (no clean)
	NOCLEAN = NOCLEAN or getParam(arg, nArg, sArg, '--noclean')
	-- Buscamos la opción -I (includes)
	INCLUDE = INCLUDE or getParam(arg, nArg, sArg, '-I')
	-- Buscamos la opción -L (libraries)
	LIBRARIES = LIBRARIES or getParam(arg, nArg, sArg, '-L')
	-- Buscamos la opción -l (libraryname)
	LIBNAME  = LIBNAME or getParam(arg, nArg, sArg, '-l')
	-- Buscamos la opción -x (executable)
	PRECOEXE = PRECOEXE or getParam(arg, nArg, sArg, '-x')
end
	
if not INCLUDE then
	INCLUDE   = '".\\include"'
	if os.getenv "LIDE_DEV" then
		INCLUDE   = '"%LIDE_DEV%\\include"'		
	end
end

if not LIBRARIES then
	LIBRARIES = '".\\lib"'
	if os.getenv "LIDE_DEV" then
		LIBRARIES = '"%LIDE_DEV%\\lib"'
	end
end

if arg[0] then
	WORK_DIR = arg[0]
	WORK_DIR = WORK_DIR:gsub(WORK_DIR:sub(#WORK_DIR -9, #WORK_DIR), '') -- 
end

if not PRECOEXE then
	PRECOEXE = WORK_DIR ..'\\ldc_win32'
end

if not LIBNAME then
	LIBNAME   = 'lua5.1'
end

if not DI_NAME then
	DI_NAME = '.'
end

if not OS_NAME then
	-- Si es Windows:
	--if io.popen("VER"):read("*a"):find("Microsoft Windows") then
	--	OS_NAME = "WIN32" -- Windows 32 bits
	--else
		-- LINUX
	--end

	-- Por defecto es Windows:
	OS_NAME = "WIN32" -- Windows 32 bits
end

if arg[1] == '--version' then
	print[[
lidec 0.0.0.1
Copyright (C) 2015 Dario Cano]]
	return
elseif arg[1] == '--help' then
	print [[
Usage: lidec [build type] [options] [modifiers]
Build types:
  APP			Compilar una aplicacion
  LIB			Compilar una libreria

Options:
  --version		Display compiler version information
  -p {WIN32|LINUX}	Plataforma de destino
  -o <file>		Output filename
  -i [lib1 lib2] 	Nombre(s) de la(s) libreria(s) a compilar
  -d <directory>	Output directory
  
  -I <directory>	Directorio donde se encuentran los includes de lua
  -L <directory>	Directorio donde se encuentran las librerias de lua
  -l <lib>		Nombre de la libreria lua
  -x <file>		Binario precompilado (Solo es util para APP)

Modifiers:
  --noclean		No limpiar los archivos intermedios

Si no se proporcionan los parametros -I, -L, -l, el compilador busca la
variable de entorno LIDE_DEV y trata de encontrar:
  $LIDE_DEV/include/lua.h
  $LIDE_DEV/include/lauxlib.h
  $LIDE_DEV/lib/lua5.1.lib
Si esta variable no existe, tratara de buscar los mismos archivos dentro
del directorio raiz.

Examples:
 Para compilar una aplicacion:
  > lidec APP -o application.exe -p WIN32 -d C:\release
	
 Para compilar una libreria:
  > lidec LIB -o modulo -i "modulo.events modulo.gui" -p WIN32 -d C:\release

For bug reporting instructions, please see:
<http://lidec.thedary.com/bugs>.]]
	os.exit()
elseif not arg[1] then
	print'not arg'
	print "Bad arguments, try: lidec --help"
	return
elseif arg[1]:upper() ~= 'APP' and arg[1]:upper() ~= 'LIB' then
	print(':'.. arg[1]..':')
	print'not applib'
	print "Bad arguments, try: lidec --help"
	return
else
	BU_TYPE = arg[1]:upper()	
end

if not BU_TYPE 
or not OS_NAME
or not EX_NAME
or not DI_NAME then
	print'DI_NAME'
	print "Bad arguments, try: lidec --help"
	return
end

if args_error then
	print'args_error'
	print "Bad arguments, try: lidec --help"
	return
end

--CLEAN = NOCLEAN == ''

if (BU_TYPE == 'APP') then	
	if not LI_NAME then
		-- Asumo que existe ./main.lua
		LI_NAME = ".\\main.lua"
	end

	if not io.open(LI_NAME) then
		io.stderr:write ("Error: "..LI_NAME.." not found.")
		return
	end

	io.stdout:write ("> Building " ..EX_NAME)

	local module_name = LI_NAME:sub(1, #LI_NAME - 4)
	
	local copy = io.popen ("copy " ..LI_NAME .. " main.lua") -- renombramos a main.lua para que la función dentro de main.c se llame: luaopen_main y no luaopen_mainprg, luaopen_miapp, etc...
	copy:close()

	--precompile(module_name, '.', DI_NAME, module_name)
	precompile("main", '.', DI_NAME, "main")
		
	LI_NAME = "main.lua"	
	compile(LI_NAME, DI_NAME)	

	if OS_NAME == "WIN32" then
		if not EX_NAME:sub(#EX_NAME -4, #EX_NAME) == '.exe' then
			EX_NAME = EX_NAME .. ".exe"
		end

		if not io.open(PRECOEXE) then
			print "Please give me a valid precompiled lide executable."
			return
		end

		local copy = io.popen("copy "..PRECOEXE.." ".. DI_NAME ..'\\'..EX_NAME, "r")
		copy:close()
		
		--os.execute("ren " .. DI_NAME ..'\\'..LI_NAME:gsub(".lua", ".dll") .." ".. EX_NAME:gsub(".exe", ".dll") )
		--if EX_NAME:sub(#EX_NAME -4, #EX_NAME) == '.exe' then
		os.execute("ren " .. DI_NAME ..'\\'..LI_NAME:gsub(".lua", ".dll") .." ".. EX_NAME:gsub(".exe", ".dll") )
		--else
		--os.execute("ren " .. DI_NAME ..'\\'..LI_NAME:gsub(".lua", ".dll") .." ".. EX_NAME ..".dll" )
		--end
	elseif OS_NAME == "LINUX" then
		--local copy = io.popen("copy %LIDE_DEV%\\prec\\linux.dat " .. DI_NAME ..'\\'..EX_NAME .. "", "r")
		--copy:close()
	end
	io.stdout:write ("\t\t\t[OK]\n")
end

if (BU_TYPE == 'LIB') then	
	--io.stdout:write ("> " ..LI_NAME:gsub('  ', ' '):gsub(' ', '\n> '))
	io.stdout:write ("> Building library: " .. EX_NAME)
	precompile(EX_NAME, '.', DI_NAME, LI_NAME)	
	compile_lib(EX_NAME, DI_NAME)

	io.stdout:write ("\t\t\t[OK]\n")
end

if NOCLEAN == nil then
	for _, filename in pairs(tempfiles) do
		local del = io.popen("cd "..DI_NAME.." & del .\\"..filename )
		del:close()
	end
end

-------------------------------------------------------------------

-- Compilar main program:
	-- lua ..\lidec.lua app -o application.exe -i main_prog.lua -pWIN32 -d release
	
	-- lidec app main.lua app.exe -osWIN32

-- Compilar librerias lua:
	-- lua ..\lidec.lua lib -o modulo -i "modulo.boton modulo.label" -pWIN32  -d release

-------------------------------------------------------------------


