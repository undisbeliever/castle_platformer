
include ../snesdev-common/makefiles/resources.makefile

.PHONY: all

all: metatilesets metatilemaps entities

.PHONY: metatilesets
metatilesets:
	$(MAKE) -C metatilesets

.PHONY: metatilemaps
metatilemaps:
	$(MAKE) -C metatilemaps


clean::
	$(MAKE) -C metatilesets clean
	$(MAKE) -C metatilemaps clean

