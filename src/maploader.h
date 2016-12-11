
.ifndef ::_MAPLOADER_H_
::_MAPLOADER_H_ = 1

.setcpu "65816"
.include "includes/import_export.inc"
.include "includes/registers.inc"
.include "includes/config.inc"

;; The segment name the map properties are in
CONFIG_DEFINE MAP_PROPERTIES_BANK, "BANK1"
;; The segment name the map entities table is in
CONFIG_DEFINE MAP_ENTITIES_TABLE_BANK, "BANK1"


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
	mapProperties		.addr
.endstruct


;; Table of entities in the map
;; First entity is the player, the rest are NPCs
.struct MapEntitiesTableStruct
	;; entity xPos
	xPos			.word
	;; entity yPos
	yPos			.word
	;; entity Init parameter
	parameter		.word
	;; entity state (address within `ENTITY_STATE_BANK`)
	entityState		.addr
.endstruct


.struct	MapPropertiesStruct
	;; Tileset to load
	tileSetId		.byte

	;; Starting map x position
	xPos			.word
	;; Starting map y position
	yPos			.word

	;; Address within `MAP_PROPERTIES_BANK` of the map entities table
	mapEntitiesTable	.addr
	;; Number of entities on the map.
	mapEntitiesTableCount	.word

	;; Address within `MAP_PROPERTIES_BANK` of the `StandingEventsTableStruct`
	;; of the level
	standingEventsTablePtr	.addr
	;; Number of entries in the standing events table.
	standingEventsTableCount .word
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


IMPORT_MODULE MapLoader
	;; Loads a map into the MetaTile1x16 module.
	;;
	;; This routine will force blank the screen, f-blank is not
	;; required (useful for processing fade out routine in NMI)
	;;
	;; REQUIRES: 8 bit A, 16 bit Index, DP = 0
	;; INPUT: A - the map number to load.
	ROUTINE	LoadMap

	;; Loads a map's tileset into the MetaTile1x16 module and VRAM.
	;;
	;; This routine will force blank the screen, f-blank is not
	;; required (useful for processing fade out routine in NMI)
	;;
	;; REQUIRES: 8 bit A, 16 bit Index, DP = 0
	;; INPUT: A - the tileset number to load.
	ROUTINE	LoadMetaTiles
ENDMODULE

.endif ; ::_MAPLOADER_H_

; vim: ft=asm:

