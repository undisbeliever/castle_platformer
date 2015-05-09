;; Map Loader

.include "maploader.h"
.include "includes/import_export.inc"
.include "includes/structure.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"

.include "routines/resourceloader.h"
.include "routines/metatiles/metatiles-1x16.h"

.include "gameloop.h"
.include "entity-physics.h"
.include "interactive-metatiles/standing-event-tile.h"


.global METATILES_BG1_MAP:absolute

METATILES_BG1_MAP   = GAMELOOP_BG1_MAP
METATILES_BG1_TILES = GAMELOOP_BG1_TILES

DEFAULT_GRAVITY = 35		; Acceleration due to gravity in 1/256 pixels per frame per frame


MODULE MapLoader

.segment "ZEROPAGE"
	FARADDR	dataPtr

.segment "SHADOW"


.code


.A8
.I16
ROUTINE LoadMap
	REP	#$30
.A16
	.assert .sizeof(MapTableFormat) = 10, error, "MapTableFormat must be 8 bytes"
	AND	#$00FF
	STA	dataPtr
	ASL
	ASL
	ADC	dataPtr ; carry clear from ASL
	ASL
	TAX

	; set default gravity
	LDA	#DEFAULT_GRAVITY
	STA	EntityPhysics__gravity

	; set the interactive tile tables.
	PHX
	JSR	SetInteractiveTileTables
	PLX

	LDA	f:MapsTable + MapTableFormat::mapData, X
	STA	dataPtr

	SEP	#$20
.A8
	LDA	f:MapsTable + MapTableFormat::mapData + 2, X
	STA	dataPtr + 2

	LDA	f:MapsTable + MapTableFormat::tileSetId, X
	PHA

	REP	#$30
.A16
	LDA	f:MapsTable + MapTableFormat::xPos, X
	STA	MetaTiles1x16__xPos
	LDA	f:MapsTable + MapTableFormat::yPos, X
	STA	MetaTiles1x16__yPos


	LDY	#MapDataPrefix::width
	LDA	[dataPtr], Y
	STA	MetaTiles1x16__mapWidth
	LDY	#MapDataPrefix::height
	LDA	[dataPtr], Y
	STA	MetaTiles1x16__mapHeight

	LDA	dataPtr
	ADD	#.sizeof(MapDataPrefix)
	TAX

	SEP	#$20
.A8
	LDA	dataPtr + 2
	LDY	#.loword(MetaTiles1x16__map)
	JSR	ResourceLoader__LoadDataToWram7E

	PLA
	JSR	LoadMetaTiles

	JMP	MetaTiles1x16__MapInit


; IN: X - MapTableFormat offset
.A16
.I16
ROUTINE SetInteractiveTileTables
	LDA	f:MapsTable + MapTableFormat::interactiveTiles, X
	TAX

	LDA	f:InteractiveTilesStructBank << 16 + InteractiveTilesStruct::standingEventsTablePtr, X
	STA	f:StandingEventTile__standingEventsTablePtr
	LDA	f:InteractiveTilesStructBank << 16 + InteractiveTilesStruct::standingEventsTableCount, X
	STA	f:StandingEventTile__standingEventsTableCount

	RTS


.A8
.I16
ROUTINE LoadMetaTiles
	REP	#$30
.A16
	.assert .sizeof(MetaTilesTableFormat) = 8, error, "MetaTilesTableFormat must be 8 bytes"
	AND	#$00FF
	ASL
	ASL
	ASL
	TAX

	LDA	f:MetaTilesTable + MetaTilesTableFormat::metaTilesData, X
	TAY

	; Copy both palette and tile ids
	LDA	f:MetaTilesTable + MetaTilesTableFormat::paletteId, X
	PHA

	LDA	f:MetaTilesTable + MetaTilesTableFormat::metaTilePropertyData, X
	PHA

	SEP	#$20
.A8
	LDA	f:MetaTilesTable + MetaTilesTableFormat::metaTilePropertyData + 2, X
	PHA


	LDA	f:MetaTilesTable + MetaTilesTableFormat::metaTilesData + 2, X
	TYX
	LDY	#.loword(MetaTiles1x16__metaTiles)
	JSR	ResourceLoader__LoadDataToWram7E


	PLA
	PLX
	LDY	#.loword(EntityPhysics__metaTilePropertyTable)
	JSR	ResourceLoader__LoadDataToWram7E

	PLA
	STZ	CGADD
	JSR	ResourceLoader__LoadPalette_8A

	PLA
	LDX	#METATILES_BG1_TILES
	STX	VMADD
	JSR	ResourceLoader__LoadVram_8A

	RTS

ENDMODULE

