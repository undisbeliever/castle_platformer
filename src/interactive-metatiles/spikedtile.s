
.include "spikedtile.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "../entities.h"
.include "../gameloop.h"

MODULE	SpikedTile

LABEL functionsTable
	.addr	PlayerStand
	.addr	PlayerTouch

.segment "WRAM7E"

.code

;; Player is standing on the tile
; DP = entity
.A16
.I16
ROUTINE PlayerStand
	RTS


;; Player is touching the tile
; DP = entity
.A16
.I16
ROUTINE PlayerTouch
	LDA	#GameState::DEAD
	STA	GameLoop__state

	RTS


ENDMODULE

