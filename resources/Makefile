
.PHONY: all

all: metatilesets metatilemaps entities

.PHONY: metatilesets
metatilesets:
	$(MAKE) -C metatilesets

.PHONY: metatilemaps
metatilemaps:
	$(MAKE) -C metatilemaps

.PHONY: entities
entities:
	$(MAKE) -C entities


clean::
	$(MAKE) -C metatilesets clean
	$(MAKE) -C metatilemaps clean
	$(MAKE) -C entities clean

