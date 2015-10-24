extern "C" {
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
}

#include <FreeImage.h>

#define BPP 24

static int l_create(lua_State *L) {
    int width = 100;
    int height = 100;
    FIBITMAP *bitmap = FreeImage_Allocate(width, height, BPP);
    return 1;
}

static int l_finalize(__attribute__((unused)) lua_State *L) {
    FreeImage_DeInitialise();
    return 0;
}

static int l_getVersion(lua_State *L) {
    const char *version = FreeImage_GetVersion();
    lua_pushstring(L, version);
    return 1;
}

static int l_init(__attribute__((unused)) lua_State *L) {
    FreeImage_Initialise(false);
    return 0;
}

static const struct luaL_reg FREE_IMAGE[] = {
    {"create", l_create},
    {"finalize", l_finalize},
    {"getVersion", l_getVersion},
    {"init", l_init},
    {NULL, NULL}
};

extern "C" int luaopen_FreeImage(lua_State *L) {
    luaL_openlib(L, "FreeImage", FREE_IMAGE, 0);
    return 1;
};

