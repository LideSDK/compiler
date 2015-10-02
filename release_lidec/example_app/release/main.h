#ifndef __MAIN__
#define __MAIN__

#include <lua.h>

#ifndef LUAOPEN_API 
#define LUAOPEN_API 
#endif

LUAOPEN_API int luaopen_main(lua_State *L);

#endif /* __MAIN__ */
