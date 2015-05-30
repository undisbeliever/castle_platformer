; Loader of resources.

; :SHOULDDO automatically generate this with a program::

.include "includes/import_export.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "maploader.h"
.include "entity-animation.h"
.include "metatileproperties.h"
.include "interactive-metatiles/standing-event-tile.h"

.include "routines/resourceloader.h"
.include "routines/metasprite.h"

; ::TODO better thing::
.include "entities/player.h"
.include "entities/npc-stomper.h"
.include "entities/npc-unmoving.h"
.include "entities/npc-walk-and-turn.h"


.enum MetatileSetId
    CASTLE_PLATFORMER
.endenum

.enum Maps
	level_01
	level_02
	level_03
.endenum

.enum PaletteId
	CASTLE_PLATFORMER
.endenum

.enum TilesId
	CASTLE_PLATFORMER
.endenum

.segment "BANK1"

MapsTable:
	.faraddr	Map_level_01
	.addr		MapProperties_level_01
	.faraddr	Map_level_02
	.addr		MapProperties_level_02
	.faraddr	Map_level_03
	.addr		MapProperties_level_03


PalettesTable:
	.faraddr	CastlePlatformer_Palette
	.byte		128


VramTable:
	.faraddr	CastlePlatformer_Tiles


MetaTilesTable:
	.faraddr	CastlePlatformer_MetaTiles
	.faraddr	CastlePlatformer_MetaTilePropertyTable
	.word		PaletteId::CASTLE_PLATFORMER
	.word		TilesId::CASTLE_PLATFORMER


; Entity Tables/Data
	.include "resources/entities/player.inc"
	.include "resources/entities/spiked-walker.inc"
	.include "resources/entities/stomper.inc"
	.include "resources/entities/walker.inc"


; Map properties
	.include "resources/metatilemaps/level_01.inc"
	.include "resources/metatilemaps/level_02.inc"
	.include "resources/metatilemaps/level_03.inc"

; Metatileset properties
	.include "resources/metatilesets/castle_platformer.inc"


.segment "BANK1"

Map_level_01:
	.incbin "resources/metatilemaps/level_01.metamap1x16"

Map_level_02:
	.incbin "resources/metatilemaps/level_02.metamap1x16"

.segment "BANK2"

Map_level_03:
	.incbin "resources/metatilemaps/level_03.metamap1x16"


.segment "BANK3"

CastlePlatformer_Palette:
	.incbin	"resources/metatilesets/castle_platformer.clr", 0, 256

CastlePlatformer_Tiles:
	.byte	VramDataFormat::UNCOMPRESSED
	.word	CastlePlatformer_Tiles_End - CastlePlatformer_Tiles - 3
	.incbin	"resources/metatilesets/castle_platformer.4bpp"
CastlePlatformer_Tiles_End:

CastlePlatformer_MetaTiles:
	.byte	MapDataFormat::UNCOMPRESSED
	.word	CastlePlatformer_MetaTiles_End - CastlePlatformer_MetaTiles - 3
	.incbin	"resources/metatilesets/castle_platformer.metatile1x16"
CastlePlatformer_MetaTiles_End:


.segment METASPRITE_FRAME_BANK
	MetaSpriteLayoutBank = .bankbyte(*)

