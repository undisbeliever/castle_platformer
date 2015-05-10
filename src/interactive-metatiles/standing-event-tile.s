
.include "standing-event-tile.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "../entity-physics.h"
.include "../standing-events/removechain.h"
.include "../standing-events/removebridge.h"
.include "../standing-events/gameover.h"

.include "routines/metatiles/metatiles-1x16.h"


MODULE	StandingEventTile

.rodata
LABEL StandingEventCommandsTable
	.addr StandingEvents_RemoveChain__RemoveChain
	.addr StandingEvents_RemoveBridge__RemoveBridge
	.addr StandingEvents_GameOver__GameOver


.code

LABEL functionsTable
	.addr	PlayerStand
	.addr	PlayerTouch


.segment "WRAM7E"
	ADDR	standingEventsTablePtr
	WORD	standingEventsTableCount
.code


;; Player is standing on the tile
; DP = EntityPhysicsStruct address
.A16
.I16
ROUTINE PlayerStand
	; x = standingEventsTablePtr
	; for y = standingEventsTableCount down to 0
	;	a = entity->standingTile
	;	if a >= StandingEventChainTable[x].maxMapLocation & a <= StandingEventChainTable[x].minMapLocation
	;		RemoveChain(StandingEventChainTable[x].chainLocation

	LDX	standingEventsTablePtr

	FOR_Y	standingEventsTableCount, DEC, #0
		LDA	z:EntityPhysicsStruct::standingTile

		CMP	f:StandingEventsTableBank << 16 + StandingEventsTableStruct::minMapLocation, X
		IF_GE
			CMP	f:StandingEventsTableBank << 16 + StandingEventsTableStruct::maxMapLocation, X
			IF_LE
				LDA	f:StandingEventsTableBank << 16 + StandingEventsTableStruct::command, X
				TAY
				LDA	f:StandingEventsTableBank << 16 + StandingEventsTableStruct::parameter, X
				TYX
				JMP	(.loword(StandingEventCommandsTable), X)
			ENDIF
		ENDIF

		TXA
		ADD	#.sizeof(StandingEventsTableStruct)
		TAX
	NEXT

	RTS


;; Player is touching the tile
; DP = EntityPhysicsStruct address
.A16
.I16
ROUTINE PlayerTouch
	RTS


.segment STANDING_EVENTS_TABLE_BANK
	StandingEventsTableBank = .bankbyte(*)

ENDMODULE

