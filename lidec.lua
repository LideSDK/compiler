LUA_EXECUTABLE = 0
LUA_LIBRARY    = 1

LINUX_X86      = 0
WINDOWS_X86    = 1

app = app or {}

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

app.folders = {}
--if 'lide.lua' == arg[0]:sub(#arg[0] - 7, #arg[0]) then
	app.folders.sourcefolder = arg[0]:sub(1, #arg[0] , #arg[0])
--end

print(app.folders.sourcefolder..'**')

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
	local preco_bin = app.preco_linux
	local cmd = ('./glue %s %s %s'):format(preco_bin, inputfile, outputfile)
	os.execute (cmd)
end

if app.input_file then
	glue_linux(app.input_file, app.output_file)
else
	print 'lidec: error fatal: no input files.'
end

