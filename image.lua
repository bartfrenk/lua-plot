-- luacheck: ignore FreeImage
do
  local path = "./freeimage.so"
  local openFreeImage = assert(package.loadlib(path, "luaopen_FreeImage"))
  openFreeImage()
end

FreeImage.init()
print("FreeImage version: "..FreeImage.getVersion())

local img = FreeImage.create(16, 16);
print(img)
img:clear(0xFF, 0xFF, 0xFF)
img:putPixel(1, 1, 0xFF, 0, 0)

img:save("test.png")

FreeImage.finalize()
