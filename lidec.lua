-- /////////////////////////////////////////////////////////////////////////////////////////////////
-- // Name:        lidec.lua
-- // Purpose:     Lua5.1 Compiler
-- // Author:      Hernán Dario Cano [dario.canohdz@gmail.com]
-- // Created:     2016/11/13
-- // Copyright:   (c) 2016 Hernan Dario Cano
-- // License:     MIT License/X11 license
-- /////////////////////////////////////////////////////////////////////////////////////////////////
--
-- GNU/Linux Lua version:   5.1.5
-- Windows x86 Lua version: 5.1.4

LUA_EXECUTABLE = 0
LUA_LIBRARY    = 1

LINUX_X86      = 0
WINDOWS_X86    = 1

app = app or {}
app.folders = {}

-- set default values:
app.output_file = 'output.out'
app.build_type  = LUA_EXECUTALE
app.build_arch  = LINUX_X86
app.input_file  = nil

app.preco_linux = 'lib/precolide_lnx86' -- x86
app.preco_win32 = 'lib/precolide_win32' -- x86

registered = {
	['-h'] = function ( ... )
		print 'Show help.'
		os.exit()
	end,

	['-o'] = function ( output )
		app.output_file = output
	end
}

registered ['--help'] = registered['-h']

if arg and arg[0] then
	local sf = arg[0]:sub(1, #arg[0] , #arg[0])
	local n  = sf:reverse():find ('/', 1 ) or sf:reverse():find ('\\', 1 ) or 0
		  sf = sf:reverse():sub (n+1, # sf:reverse()) : reverse()
	_sourcefolder = sf
end

if not app.preco_linux or not app.preco_win32 then
	print('No se encuentra:\n%s\n%s', app.preco_linux, app.preco_win32)
	os.exit()
end

function read_args ( arg )
	for i = 1, #arg do
		if registered[arg[i]] then
			registered[arg[i]](arg[i+1]) -- always pass the next arg
		else
			if arg[i] then
				app.input_file = tostring(arg[i]);
			end
		end
	end
end

read_args(arg)

function glue_linux ( inputfile, outputfile)
	local file, errm = io.open (inputfile);
	if not file then
		local message = 'lidec: Error: %s'
		print(message:format(errm))
		return false
	end

	local preco_bin = app.preco_linux
	local cmd = ('./glue %s %s %s'):format(preco_bin, inputfile, outputfile)
	os.execute (cmd)
end

if app.input_file then
	glue_linux(app.input_file, app.output_file)
else
	print 'lidec: error fatal: no input files.'
end

