
.include "removebridge.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "../gameloop.h"


MODULE	StandingEvents_LoadMap


; IN: A - map to load
; DP = entity
.A16
.I16
ROUTINE LoadMap
	SEP	#$20
.A8
	STA	GameLoop__map

	LDA	#GameState::LOAD_NEW_MAP
	STA	GameLoop__state

	REP	#$30
.A16
	RTS

ENDMODULE

