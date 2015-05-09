.ifndef ::_METATILEPROPERTIES_H_
::_METATILEPROPERTIES_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"
.include "entity-physics.h"


IMPORT_MODULE TileProperties
	LABEL	EmptyTile
	LABEL	SolidTile
	LABEL	IcePlatform
	LABEL	Platform
	LABEL	Chain
	LABEL	StandingEventTile
	LABEL	Spikes
ENDMODULE

.endif ; ::_METATILEPROPERTIES_H_

; vim: set ft=asm:

