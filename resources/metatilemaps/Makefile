
FILES = $(wildcard *.tmx)
MAPS  = $(patsubst %.tmx,%.metamap1x16,$(FILES))

CONVERT_TMX_METAMAP1x16 = python3 ../../utils/tmx2metamap1x16.py

.PHONY: ALL

ALL: $(MAPS)

%.metamap1x16: %.tmx
	$(CONVERT_TMX_METAMAP1x16) $*.tmx $*.metamap1x16

.PHONY: clean
clean:
	$(RM)  $(MAPS)

