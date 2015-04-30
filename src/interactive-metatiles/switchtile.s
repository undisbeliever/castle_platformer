
.include "switchtile.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "../entities.h"

.include "routines/metatiles/metatiles-1x16.h"

.struct SwitchChainStruct
	minMapLocation	.addr
	maxMapLocation	.addr
	chainLocation	.addr
.endstruct

MODULE	SwitchTile

LABEL functionsTable
	.addr	PlayerStand
	.addr	PlayerTouch


.segment "WRAM7E"
	ADDR	currentChainPieceToRemove
	WORD	chainTile
	BYTE	frameDelay

.code

REMOVE_CHAIN_FRAME_DELAY = 6
RATTLE_SCREEN_AMOUNT = 3

; ::TODO redo, maybe I should allocate some DP space for the functions?::
; ::: That way I don't have to space the tiles so far apart?::
.global GameLoop__execOncePerFrame

;; Player is standing on the tile
; DP = entity
.A16
.I16
ROUTINE PlayerStand
	; for x = 0 to .sizeof(SwitchChainTable) step .sizeof(SwitchChainStruct)
	;	a = entity->standingTile
	;	if a >= SwitchChainTable[x].maxMapLocation & a <= SwitchChainTable[x].minMapLocation
	;		RemoveChain(SwitchChainTable[x].chainLocation

	; ::TODO use RAM loaded table?::
	; ::TODO make function dynamic::
	LDX	#0
	LDY	z:EntityStruct::standingTile

	REPEAT
		TYA

		CMP	f:SwitchChainTable + SwitchChainStruct::minMapLocation, X
		IF_GE
			CMP	f:SwitchChainTable + SwitchChainStruct::maxMapLocation, X
			IF_LE
				LDA	f:SwitchChainTable + SwitchChainStruct::chainLocation, X
				BRA	RemoveChain
			ENDIF
		ENDIF

		TXA
		ADD	#.sizeof(SwitchChainStruct)
		TAX
		; ::TODO dynamically determine size::	
		CPX	#SwitchChainTable_End - SwitchChainTable
	UNTIL_GE

	RTS


;; Player is touching the tile
; DP = entity
.A16
.I16
ROUTINE PlayerTouch
	RTS



; IN: A - chainLocation
; DP = entity
.A16
.I16
ROUTINE RemoveChain
	; x = chainLocation
	; tile = MetaTiles1x16__map[x]
	; if tile != 0
	;	frameDelay = 0
	;	currentChainPieceToRemove = x
	;	chainTile = x + MetaTiles1x16__sizeOfMapRow
	;
	;	GameLoop__execOncePerFrame = RemoveChainTimerCallback

	TAX

	; Check if chain already removed, and setup callback.
	LDA	.loword(MetaTiles1x16__map), X
	IF_NOT_ZERO
		SEP	#$20
.A8
		; ensure chain is removed immediatly
		STZ	frameDelay
		REP	#$20
.A16

		STX	currentChainPieceToRemove

		TXA
		SUB	MetaTiles1x16__sizeOfMapRow
		TAX
		LDA	.loword(MetaTiles1x16__map), X
		STA	chainTile

		; ::TODO redo this bit, probably use DP allocation like Entities?::

		LDX	#.loword(RemoveChainTimer)
		STX	GameLoop__execOncePerFrame
	ENDIF

	RTS


;; Removes a single chain tile every REMOVE_CHAIN_FRAME_DELAY frames.
;; REGISTERS: 16 bit A, 16 bit Index, DB = $7E, DP = 0
;; OUTPUT: c set if function continues next frame, c clear if this is the last frame.
.A16
.I16
ROUTINE RemoveChainTimer
	; if frameDelay != 0
	;	frameDelay--
	;	return true
	; else
	; 	frameDelay = REMOVE_CHAIN_FRAME_DELAY
	;	// SOUND - remove chain
	;	MetaTiles1x16__mapDirty = 1
	;
	;	MetaTiles1x16__map[currentChainPieceToRemove] = 0
	;
	;	currentChainPieceToRemove -= MetaTiles1x16__sizeOfMapRow
	;	if currentChainPieceToRemove < 0
	;		return false
	;
	;	MetaTiles1x16__map[currentChainPieceToRemove] != chainTile
	;		return false
	;	

	SEP	#$20
.A8
	LDA	frameDelay
	IF_NOT_ZERO
		; rattle the screen - show something is happening
		.assert REMOVE_CHAIN_FRAME_DELAY & 1 = 0, error, "REMOVE_CHAIN_FRAME_DELAY must be even to rattle screen properly"
		LSR

		LDA	MetaTiles1x16__yPos
		IF_C_CLEAR
			; a clear
			ADC	#RATTLE_SCREEN_AMOUNT
		ELSE
			; c already set
			SBC	#RATTLE_SCREEN_AMOUNT
		ENDIF
		STA	MetaTiles1x16__yPos

		DEC	frameDelay
		SEC
		RTS	
	ENDIF

	LDA	#REMOVE_CHAIN_FRAME_DELAY
	STA	frameDelay

	; ::SOUND remove chain::

	LDA	#1
	STA	.loword(MetaTiles1x16__mapDirty)

	REP	#$30
.A16

	LDX	currentChainPieceToRemove
	STZ	.loword(MetaTiles1x16__map), X

	TXA
	SUB	MetaTiles1x16__sizeOfMapRow
	IF_MINUS
		CLC
		RTS
	ENDIF
	STA	currentChainPieceToRemove

	TAX
	LDA	.loword(MetaTiles1x16__map), X
	CMP	chainTile
	IF_NE
		CLC
		RTS
	ENDIF

	SEC
	RTS


.segment "BANK1"
	; ::TODO make this table dynamic per level::

LABEL	SwitchChainTable
	;	minMapLocation     , minMapLocation     , chainLocation
	.word	(13 * 112 + 28) * 2, (13 * 112 + 31) * 2, (13 * 112 + 33) * 2
	.word	(26 * 112 + 29) * 2, (26 * 112 + 32) * 2, (12 * 112 + 95) * 2
	.word	(51 * 112 + 45) * 2, (51 * 112 + 48) * 2, (12 * 112 + 98) * 2
SwitchChainTable_End:


ENDMODULE

