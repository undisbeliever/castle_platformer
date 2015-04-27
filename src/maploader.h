
.ifndef ::_MAPLOADER_H_
::_MAPLOADER_H_ = 1

.setcpu "65816"
.include "includes/import_export.inc"
.include "includes/registers.inc"

.enum	MapDataFormat
	UNCOMPRESSED	= 0
.endenum

.struct	DataContainer
	dataFormat	.byte
	dataSize	.word
	; Then the data stored in `dataFormat`
.endstruct



.struct MapDataPrefix
	width		.word
	height		.word
.endstruct


.struct MapTableFormat
	mapData		.faraddr
	tileSetId	.byte
	xPos		.word
	yPos		.word
.endstruct

;; A table of `MapTableFormat`, one for each map
.global	MapsTable


.struct	MetaTilesTableFormat
	metaTilesData		.faraddr
	metaTilePropertyData	.faraddr
	paletteId		.byte
	tilesId			.byte
.endstruct

;; A table of `MetaTilesTableFormat`, one for each tileset
.global	MetaTilesTable



METATILES_SCREEN_MODE	= BGMODE_MODE1
METATILES_BG1_MAP 	= $0000
METATILES_BG1_TILES	= $3000
METATILES_BG1_SIZE	= BGXSC_SIZE_64X32
; ::SHOULDDO move somewhere else::
METATILES_OAM_TILES	= $6000

METATILES_OAM_SIZE	= OBSEL_SIZE_8_16
METATILES_OAM_NAME	= 0


IMPORT_MODULE MapLoader
	;; Loads a map into the MetaTile1x16 module.
	;; REQUIRES: 8 bit A, 16 bit Index, DP = 0, Force Blank
	;; INPUT: A - the map number to load. 
	ROUTINE	LoadMap

	;; Loads a map's tileset into the MetaTile1x16 module and VRAM.
	;; REQUIRES: 8 bit A, 16 bit Index, DP = 0, Force Blank
	;; INPUT: A - the tilemap number to load.
	ROUTINE	LoadTileset
ENDMODULE

.endif ; ::_MAPLOADER_H_

; vim: ft=asm:

