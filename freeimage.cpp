extern "C" {
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
}

#include <FreeImage.h>

#define BPP 24
#define IMAGE_FORMAT FIF_PNG

// TODO: put static functions in anonymous namespace

struct Point {
    size_t x;
    size_t y;
};

static FIBITMAP **checkFreeImage(lua_State *L, int narg) {
    void *udata = luaL_checkudata(L, narg, "FreeImage.methods");
    luaL_argcheck(L, udata != NULL, narg, "Expected a FreeImage bitmap");
    return (FIBITMAP **) udata;
}

static RGBQUAD checkColor(lua_State *L, int narg) {
    RGBQUAD color;
    color.rgbRed = luaL_checkinteger(L, narg);
    color.rgbGreen = luaL_checkinteger(L, narg + 1);
    color.rgbBlue = luaL_checkinteger(L, narg + 2);
    return color;
}

static Point checkPoint(lua_State *L, int narg) {
    Point point;
    point.x = luaL_checkinteger(L, narg);
    point.y = luaL_checkinteger(L, narg + 1);
    return point;
}

static int l_create(lua_State *L) {
    int n = lua_gettop(L);
    if (n != 2)
        return luaL_error(L, "Expected 2 arguments instead of %d", n);
    int width = luaL_checkinteger(L, 1);
    int height = luaL_checkinteger(L, 2);
    if (height < 1 || width < 1)
        return luaL_error(L, "Width and height need to be positive integers");

    FIBITMAP **bitmap = (FIBITMAP **) lua_newuserdata(L, sizeof(FIBITMAP *));
    *bitmap = FreeImage_Allocate(width, height, BPP);

    luaL_getmetatable(L, "FreeImage.methods");
    lua_setmetatable(L, -2);
    return 1;
}

static int l_destroy(lua_State *L) {
    FIBITMAP **bitmap = checkFreeImage(L, 1);
    FreeImage_Unload(*bitmap);
    return 0;
}

static int l_finalize(__attribute__((unused)) lua_State *L) {
    FreeImage_DeInitialise();
    return 0;
}

static int l_getCopyrightMessage(lua_State *L) {
    const char *message = FreeImage_GetCopyrightMessage();
    lua_pushstring(L, message);
    return 1;
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

static int l_putLine(lua_State *L) {
    FIBITMAP **bitmap = checkFreeImage(L, 1);
    Point p = checkPoint(L, 2);
    Point q = checkPoint(L, 4);
    RGBQUAD color = checkColor(L, 6);
}

static int l_putPixel(lua_State *L) {
    // TODO: check arguments
    FIBITMAP **bitmap = checkFreeImage(L, 1);
    Point point = checkPoint(L, 2);
    RGBQUAD color = checkColor(L, 4);
    FreeImage_SetPixelColor(*bitmap, point.x, point.y, &color);
    return 0;
}

static int l_size(lua_State *L) {
    FIBITMAP **bitmap = checkFreeImage(L, 1);
    size_t width = FreeImage_GetWidth(*bitmap);
    size_t height = FreeImage_GetHeight(*bitmap);
    lua_pushinteger(L, width);
    lua_pushinteger(L, height);
    return 2;
}

static int l_save(lua_State *L) {
    FIBITMAP **bitmap = checkFreeImage(L, 1);
    const char* name = luaL_checkstring(L, 2);
    bool result = FreeImage_Save(IMAGE_FORMAT, *bitmap, name);
    lua_pushboolean(L, result);
    return 1;
}

static int l_clear(lua_State *L) {
    FIBITMAP **bitmap = checkFreeImage(L, 1);
    RGBQUAD color = checkColor(L, 2);
    size_t width = FreeImage_GetWidth(*bitmap);
    size_t height = FreeImage_GetHeight(*bitmap);
    for (size_t x = 0; x < width; ++x)
        for (size_t y = 0; y < height; ++y)
            FreeImage_SetPixelColor(*bitmap, x, y, &color);
    return 0;
}

static int l_tostring(lua_State *L) {
    FIBITMAP **bitmap = checkFreeImage(L, 1);
    size_t width = FreeImage_GetWidth(*bitmap);
    size_t height = FreeImage_GetHeight(*bitmap);
    lua_pushfstring(L, "FreeImage: %d x %d", width, height);
    return 1;
}

static const struct luaL_reg FUNCTIONS[] = {
    {"create", l_create},
    {"finalize", l_finalize},
    {"getCopyrightMessage", l_getCopyrightMessage},
    {"getVersion", l_getVersion},
    {"init", l_init},
    {NULL, NULL}
};


static const struct luaL_reg METHODS[] = {
    {"__gc", l_destroy},
    {"__tostring", l_tostring},
    {"putPixel", l_putPixel},
    {"save", l_save},
    {"clear", l_clear},
    {"size", l_size},
    {NULL, NULL}
};

extern "C" int luaopen_FreeImage(lua_State *L) {
    luaL_newmetatable(L, "FreeImage.methods");

    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2);
    lua_settable(L, -3);
    luaL_openlib(L, NULL, METHODS, 0);

    luaL_openlib(L, "FreeImage", FUNCTIONS, 0);

    return 1;
};

