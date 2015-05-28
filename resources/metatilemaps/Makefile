
FILES = $(wildcard *.tmx)
MAPS  = $(patsubst %.tmx,%.metamap1x16,$(FILES))
INCS  = $(patsubst %.tmx,%.inc,$(FILES))

CONVERT_TMX_METAMAP1x16_FILE = ../../utils/tmx2metamap1x16.py
CONVERT_TMX_METAMAP1x16 = python3 ../../utils/tmx2metamap1x16.py

.PHONY: ALL

ALL: $(MAPS) $(INCS)

%.metamap1x16 %.inc: %.tmx $(CONVERT_TMX_METAMAP1x16_FILE)
	$(CONVERT_TMX_METAMAP1x16) $*.tmx $*.metamap1x16 $*.inc

.PHONY: clean
clean:
	$(RM)  $(MAPS)

