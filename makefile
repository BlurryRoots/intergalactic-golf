name = NoName

all: repack run

repack:
	rm -f bin/$(name).love
	zip -9qr bin/$(name).love gfx lib sfx src *.lua

run:
	love bin/$(name).love
