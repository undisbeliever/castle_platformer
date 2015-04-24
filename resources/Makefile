
MAPS = 
TILES = 
MODE7 = 
MODE7TILES = $(patsubst %,%.pc7,$(MODE7))
MODE7MAPS = $(patsubst %,%.mp7,$(MODE7))

PALETTES =  $(patsubst %.2bpp,%.clr,$(patsubst %.4bpp,%.clr,$(TILES))) $(patsubst %,%.clr,$(MODE7))

.PHONY: ALL

ALL: metatilesets metatilemaps $(TILES) $(MAPS) $(MODE7TILES) $(MODE7MAPS) $(META) $(PALETTES)

%.2bpp %.clr: %.pcx
	pcx2snes -n -s8 -c4 -o4 $*
	mv $*.pic $*.2bpp

%.4bpp %.clr: %.pcx
	pcx2snes -n -s8 -c16 -o16 $*
	mv $*.pic $*.4bpp

%.map %.4bpp %.clr: %.pcx
	pcx2snes -r -s8 -c16 -screen $*
	mv $*.pic $*.4bpp

%.mp7 %.pc7 %.clr: %.pcx
	pcx2snes -screen7 $*


.PHONY: metatilesets
metatilesets:
	cd metatilesets/ && $(MAKE)

.PHONY: metatilemaps
metatilemaps:
	cd metatilemaps/ && $(MAKE)


.PHONY: clean
clean:
	$(RM)  $(TILES) $(MAPS) $(MODE7TILES) $(MODE7MAPS) $(META) $(PALETTES)
	cd metatilesets/ && $(MAKE) clean
	cd metatilemaps/ && $(MAKE) clean


.PRECIOUS: $(PALETTES)

