LUA_LIBS = $(shell pkg-config lua5.1 --cflags)
LUA_INCLUDES = $(shell pkg-config lua5.1 --libs)
LUA_ALL = $(shell pkg-config lua5.1 --cflags --libs)
OPTIONS =
CC = g++

.PHONY: all clean exec

all: freeimage.so

exec: freeimage

freeimage.o: freeimage.cpp
	$(CC) -c -fPIC $< -o $@ $(OPTIONS) $(LUA_LIBS)

freeimage.so: freeimage.o
	$(CC) -shared -o $@ $< $(OPTIONS) $(LUA_INCLUDES) -lfreeimage

freeimage: freeimage.cpp
	$(CC) $< -o $@ $(LUA_ALL) -lm -lfreeimage

clean:
	@rm -rf *.o *.so
