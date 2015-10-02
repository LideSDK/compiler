-- llc -i main.lua -o main.dll
-- llc -i 'modulo.boton modulo.label' -o modulo.dll

function precompile ( output, rootdir, outputdir, input_names)
	os.execute ('precompiler -o '..output..' -l "'..rootdir..'\\?.lua" -d "'..outputdir..'" -n ' .. input_names)
	table.insert(tempfiles, output..".c")
	table.insert(tempfiles, output..".h")
end

function compile_lib( module_name, outputdir )
	local lib_ext = '.dll'
	os.execute ('gcc -O2 -m32 -c -o '..outputdir.."\\"..module_name..'.o '..outputdir.."\\"..module_name..'.c -I'.. INCLUDE)
	os.execute ('gcc -O -m32 -shared -o '..outputdir.."\\"..module_name..lib_ext..' '..outputdir.."\\"..module_name..'.o -L'..LIBRARIES..' -l'..LIBNAME) -- OJO! PARA LINUX LOS LIBS PODRIAN CAMBIAR
	table.insert(tempfiles, module_name..".o")
end
tempfiles ={}
pif = true

for argn, args in pairs(arg) do
	if (args == '-i') then
		inputFile = arg[argn +1]
	elseif (args == '-o') then
		outputFile = arg[argn +1]
	end
end

LIBNAME   = 'lua5.1'
INCLUDE   = '"%LIDE_DEV%\\include"'		
LIBRARIES = '".\\lib"'
LIBRARIES = '"%LIDE_DEV%\\lib"'

print('inputFile:' , inputFile )
print('outputFile:', outputFile)

if outputFile:sub(#outputFile-4, #outputFile) then
	-- Eliminar	la extension
	module_name = outputFile:sub(1, #outputFile -4)
else
	module_name = outputFile
end


precompile ( module_name, '.', '.', inputFile)
compile_lib( module_name, '.')

-- llc -i "modulo.boton modulo.label" -o modulo.dll