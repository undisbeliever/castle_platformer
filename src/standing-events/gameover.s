
.include "removebridge.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "../gameloop.h"


MODULE	StandingEvents_GameOver


; Sets the game state to GAME_OVER
; IN: A - 0
; DP = entity
.A16
.I16
ROUTINE GameOver
	SEP	#$20
.A8

	LDA	#GameState::GAME_OVER
	STA	GameLoop__state

	REP	#$30
.A16
	RTS

ENDMODULE

