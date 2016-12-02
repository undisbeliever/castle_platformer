# REQUIRES ImageMagick
# If a tileset has a file labelled *.overlay.png than the tileset png
# will contain both the .pcx and the .overlay.png images.

FILES    = $(wildcard *.pcx)
TILES    = $(patsubst %.pcx,%.4bpp,$(FILES))
LAYOUTS  = $(patsubst %.pcx,%.metatile1x16,$(FILES))
PALETTES = $(patsubst %.pcx,%.clr,$(FILES))
PNGS	 = $(patsubst %.pcx,%.png,$(FILES))

CONVERT_MAP_METATILE1X16_FILE = ../../utils/map2metatile1x16.py
CONVERT_MAP_METATILE1X16 = python3 ../../utils/map2metatile1x16.py

.PHONY: ALL

ALL: $(TILES) $(LAYOUTS) $(PALETTES) $(PNGS)

%.metatile1x16 %.4bpp %.clr: %.pcx $(CONVERT_MAP_METATILE1X16_FILE)
	pcx2snes -r -s8 -c16 -screen $*
	$(CONVERT_MAP_METATILE1X16) $*.map $*.metatile1x16
	$(RM) $*.map
	mv $*.pic $*.4bpp

%.png: %.pcx %.overlay.png
	composite $*.overlay.png $*.pcx $*.png

%.png: %.pcx
	convert $*.pcx $*.png


.PHONY: clean
clean:
	$(RM)  $(TILES) $(LAYOUTS) $(PALETTES) $(PNGS)

.PRECIOUS: $(PALETTES)

