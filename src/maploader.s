;; Map Loader

.include "maploader.h"
.include "includes/import_export.inc"
.include "includes/structure.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"

.include "routines/resourceloader.h"
.include "routines/metatiles/metatiles-1x16.h"


.global METATILES_BG1_MAP:absolute


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
	.assert .sizeof(MapTableFormat) = 8, error, "MapTableFormat must be 8 bytes"
	AND	#$00FF
	ASL
	ASL
	ASL
	TAX

	LDA	f:MapsTable + MapTableFormat::ptr, X
	STA	dataPtr

	SEP	#$20
.A8
	LDA	f:MapsTable + MapTableFormat::ptr + 2, X
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



.A8
.I16
ROUTINE LoadMetaTiles
	REP	#$30
.A16
	.assert .sizeof(MetaTilesTableFormat) = 5, error, "MetaTilesTableFormat must be 5 bytes"
	AND	#$00FF
	STA	dataPtr
	ASL
	ASL
	ADC	dataPtr		; c always clear
	TAX

	LDA	f:MetaTilesTable + MetaTilesTableFormat::metaTilesPtr, X
	STA	dataPtr

	; Copy both palette and tile ids
	LDA	f:MetaTilesTable + MetaTilesTableFormat::paletteId, X
	PHA

	SEP	#$20
.A8
	LDA	f:MetaTilesTable + MetaTilesTableFormat::metaTilesPtr + 2, X
	LDX	dataPtr
	LDY	#.loword(MetaTiles1x16__metaTiles)
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

