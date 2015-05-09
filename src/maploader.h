
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
	width			.word
	height			.word
.endstruct


.struct MapTableFormat
	mapData			.faraddr
	tileSetId		.byte
	xPos			.word
	yPos			.word
	interactiveTiles	.addr
.endstruct

.struct	InteractiveTilesStruct
	; Address within `SwitchTileTableBank` of the switchtile of the level
	standingEventsTablePtr	.addr
	; Number of entries in the switchtile table.
	standingEventsTableCount	.word
.endstruct

.global InteractiveTilesStructBank : zp

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

