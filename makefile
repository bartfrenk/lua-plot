LUA_LIBS = $(shell pkg-config lua5.1 --cflags)
LUA_INCLUDES = $(shell pkg-config lua5.1 --libs)
LUA_ALL = $(shell pkg-config lua5.1 --cflags --libs)
OPTIONS =
CC = g++

.PHONY: all clean

all: freeimage.so

freeimage.o: freeimage.cpp
	$(CC) -c -fPIC -o $@ $(OPTIONS) $< $(LUA_LIBS)

freeimage.so: freeimage.o
	$(CC) -shared -o $@ $< $(OPTIONS) -lfreeimage $(LUA_INCLUDES)

clean:
	@rm -rf *.o *.so
