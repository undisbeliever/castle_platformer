
FILES    = $(wildcard *.pcx)
TILES    = $(patsubst %.pcx,%.4bpp,$(FILES))
LAYOUTS  = $(patsubst %.pcx,%.metatile1x16,$(FILES))
PALETTES = $(patsubst %.pcx,%.clr,$(FILES))
PNGS	 = $(patsubst %.pcx,%.png,$(FILES))

CONVERT_MAP_METATILE1X16 = python3 ../../utils/map2metatile1x16.py
PCX2PNG = convert

.PHONY: ALL

ALL: $(TILES) $(LAYOUTS) $(PALETTES) $(PNGS)

%.metatile1x16 %.4bpp %.clr: %.pcx
	# ::TODO better conversion program, one that handles tile flipping::
	pcx2snes -r -s8 -c16 -screen $*
	$(CONVERT_MAP_METATILE1X16) $*.map $*.metatile1x16
	$(RM) $*.map
	mv $*.pic $*.4bpp

%.png: %.pcx
	$(PCX2PNG) $*.pcx $*.png

.PHONY: clean
clean:
	$(RM)  $(TILES) $(LAYOUTS) $(PALETTES) $(PNGS)

.PRECIOUS: $(PALETTES)

