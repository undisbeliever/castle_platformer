
ROM_NAME      = Castle_Platformer
CONFIG        = LOROM_1MBit_copyright
API_MODULES   = reset-snes block screen math resourceloader metasprite metatiles/metatiles-1x16 background-events
API_DIR       = snesdev-common
SOURCE_DIR    = src
RESOURCES_DIR = resources

include $(API_DIR)/Makefile.in

