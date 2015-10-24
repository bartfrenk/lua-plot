-- luacheck: ignore FreeImage
do
  local path = "./freeimage.so"
  local openFreeImage = assert(package.loadlib(path, "luaopen_FreeImage"))
  openFreeImage()
end

FreeImage.init()
print("FreeImage version: "..FreeImage.getVersion())
FreeImage.finalize()
