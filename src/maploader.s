;; Map Loader

.include "maploader.h"
.include "includes/import_export.inc"
.include "includes/structure.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"

.include "routines/resourceloader.h"
.include "routines/metatiles/metatiles-1x16.h"

.include "gameloop.h"
.include "entities.h"
.include "entity-physics.h"
.include "interactive-metatiles/standing-event-tile.h"


.global METATILES_BG1_MAP:absolute

METATILES_BG1_MAP   = GAMELOOP_BG1_MAP
METATILES_BG1_TILES = GAMELOOP_BG1_TILES


MODULE MapLoader

.importzp ResourceLoader__dataPtr

;	dataPtr = ResourceLoader__dataPtr'

.zeropage
	FARADDR	dataPtr

.segment "SHADOW"
	WORD	tmp

.segment "WRAM7E"
	WORD	count
	WORD	entitiesTableAddr

.code


.A8
.I16
ROUTINE LoadMap
	REP	#$30
.A16
	.assert .sizeof(MapTableFormat) = 5, error, "MapTableFormat must be 5 bytes"
	AND	#$00FF
	STA	dataPtr
	ASL
	ASL
	ADC	dataPtr ; carry clear from ASL
	TAX

	; set default gravity
	; -------------------
	LDA	#DEFAULT_GRAVITY
	STA	f:EntityPhysics__gravity


	PHX

	; load map properties
	; -------------------

	LDA	f:MapsTable + MapTableFormat::mapProperties, X
	TAX

	LDA	f:MapPropertiesBank << 16 + MapPropertiesStruct::tileSetId, X
	STA	tmp

	LDA	f:MapPropertiesBank << 16 + MapPropertiesStruct::xPos, X
	STA	MetaTiles1x16__xPos
	LDA	f:MapPropertiesBank << 16 + MapPropertiesStruct::yPos, X
	STA	MetaTiles1x16__yPos

	LDA	f:MapPropertiesBank << 16 + MapPropertiesStruct::standingEventsTablePtr, X
	STA	f:StandingEventTile__standingEventsTablePtr
	LDA	f:MapPropertiesBank << 16 + MapPropertiesStruct::standingEventsTableCount, X
	STA	f:StandingEventTile__standingEventsTableCount

	JSR	LoadEntities


	; load map data
	; -------------

	PLX
	LDA	f:MapsTable + MapTableFormat::mapData, X
	STA	dataPtr

	SEP	#$20
.A8
	LDA	f:MapsTable + MapTableFormat::mapData + 2, X
	STA	dataPtr + 2

	REP	#$30
.A16

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

	LDA	tmp
	JSR	LoadMetaTiles

	JMP	MetaTiles1x16__MapInit


; IN: X - MapPropertiesStruct offset
.A16
.I16
ROUTINE LoadEntities
	PHB

	PEA	$7E7E
	PLB
	PLB

	PHX
	JSR	Entities__Init
	PLX

	LDA	f:MapPropertiesBank << 16 + MapPropertiesStruct::mapEntitiesTableCount, X
	STA	a:count

	LDA	f:MapPropertiesBank << 16 + MapPropertiesStruct::mapEntitiesTable, X
	STA	a:entitiesTableAddr
	TAX

	; First entity is the player
	LDA	f:MapEntitiesTableBank << 16 + MapEntitiesTableStruct::xPos, X
	PHA
	LDA	f:MapEntitiesTableBank << 16 + MapEntitiesTableStruct::yPos, X
	TAY
	LDA	f:MapEntitiesTableBank << 16 + MapEntitiesTableStruct::parameter, X
	STA	Entities__parameter
	LDA	f:MapEntitiesTableBank << 16 + MapEntitiesTableStruct::entityState, X
	PLX
	JSR	Entities__NewPlayer

	REPEAT
		DEC	a:count
	WHILE_NOT_ZERO
		LDA	entitiesTableAddr
		ADD	#.sizeof(MapEntitiesTableStruct)
		STA	entitiesTableAddr
		TAX

		; Rest of the table are NPCs
		LDA	f:MapEntitiesTableBank << 16 + MapEntitiesTableStruct::xPos, X
		PHA
		LDA	f:MapEntitiesTableBank << 16 + MapEntitiesTableStruct::yPos, X
		TAY
		LDA	f:MapEntitiesTableBank << 16 + MapEntitiesTableStruct::parameter, X
		STA	Entities__parameter
		LDA	f:MapEntitiesTableBank << 16 + MapEntitiesTableStruct::entityState, X
		PLX
		JSR	Entities__NewNpc
	WEND

	PLB
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

	; Ensure in force-blank
	LDA	#INIDISP_FORCE
	STA	INIDISP

	PLA
	STZ	CGADD
	JSR	ResourceLoader__LoadPalette_8A

	PLA
	LDX	#METATILES_BG1_TILES
	STX	VMADD
	JSR	ResourceLoader__LoadVram_8A

	RTS


.segment MAP_PROPERTIES_BANK
	MapPropertiesBank = .bankbyte(*)

.segment MAP_ENTITIES_TABLE_BANK
	MapEntitiesTableBank = .bankbyte(*)

ENDMODULE

