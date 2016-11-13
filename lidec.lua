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

print = { lua = print }

local function locals(lvel)
   	local variables = {}
   	local idx = 1
   	while true do
    	local ln, lv = debug.getlocal(2 +(lvel or 0), idx)
      	if ln ~= nil then
      		variables[ln] = lv
    	else
      		break
    	end
    	idx = 1 + idx
  	end
  	return variables
end

local function upvalues()
  	local variables = {}
  	local idx = 1
  	local func = debug.getinfo(2 + (lvel or 0), "f").func
  	
  	while true do
    	local ln, lv = debug.getupvalue(func, idx)
    	if ln ~= nil then
    		variables[ln] = lv
    	else
    		break
    	end
    	idx = 1 + idx
 	end
  	return variables
end

local function globals( ... )
	return _G
end

print.error = function ( str )
	local var_value, var_name, pr1, pr2, pr3, pr4

	if str:find '%$' then
	    pr1, pr2  = str:find('%$');
	    pr3, pr4  = str:find('%$', (pr1 or 0)+2);
	   
	    var_name  = str:sub((pr1 or 0) +1, pr3 -1);

	    if var_name:find '%.' then
	   		local tbl_var = var_name:sub(1, var_name:find('%.')-1);
	   		local idx_var = var_name:sub(var_name:find('%.')+1, #var_name);
	   		var_value = locals (1)  [tbl_var] or upvalues(1) [tbl_var]  or globals() [tbl_var]
	    else
	   		var_value = locals (1)  [var_name] or upvalues(1) [var_name]  or globals() [var_name]
	    end
	    
	    if not var_value then
			assert( false, ('lide: error fatal: la variable "%s" no existe..'):format (var_name) )
		end

		print( str:sub(1, pr1-1) .. tostring(var_value) .. str:sub(pr4 +1, #str))
	else
		print( str )
	end

	
end

setmetatable( print, { __call = function ( self, ... )
	print.lua ( ... )
end })

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
		print.error 'lidec: error: $errm$.'
		return false
	end

	local preco_bin = app.preco_linux
	local cmd = ('./glue %s %s %s'):format(preco_bin, inputfile, outputfile)
	os.execute (cmd)
end

if app.input_file then
	glue_linux(app.input_file, app.output_file)
else
	print.error 'lidec: error fatal: no input files.'
end