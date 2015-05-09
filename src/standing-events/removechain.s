
.include "removechain.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "routines/background-events.h"
.include "routines/metatiles/metatiles-1x16.h"

REMOVE_CHAIN_FRAME_DELAY = 6
RATTLE_SCREEN_AMOUNT = 3

BACKGROUND_EVENT_STRUCT EventStruct
	frameDelay			.byte
	currentChainPieceToRemove	.addr
	chainTile			.word
	chainBottomTile			.word
END_BACKGROUND_EVENT_STRUCT

MODULE	StandingEvents_RemoveChain

; IN: A - chain location on map
; DP = entity
.A16
.I16
ROUTINE RemoveChain
	; tile = MetaTiles1x16__map[chainLocation]
	; if tile != 0
	;	entity = BackgroundEvents__NewEvent(RemoveChainEvent)
	;
	;	if entity
	;		entity->frameDelay = 0
	;		entity->chainBottomTile = MetaTiles1x16__map[chainLocation]
	;		entity->currentChainPieceToRemove = chainLocation
	;		entity->chainTile = chainLocation + MetaTiles1x16__sizeOfMapRow

	TAX

	; Check if chain already removed, and setup callback.
	LDA	.loword(MetaTiles1x16__map), X
	IF_NOT_ZERO
		PHX

		LDX	#.loword(RemoveChainEvent)
		JSR	BackgroundEvents__NewEvent

		PLY

		IF_C_SET
			LDA	.loword(MetaTiles1x16__map), Y
			STA	a:EventStruct::chainBottomTile, X

			; ensure chain is removed immediatly, safe to write in 16 bit mode
			STZ	a:EventStruct::frameDelay, X

			TYA
			STA	a:EventStruct::currentChainPieceToRemove, X
			SUB	a:MetaTiles1x16__sizeOfMapRow
			TAY
			LDA	.loword(MetaTiles1x16__map), Y
			STA	a:EventStruct::chainTile, X
		ENDIF
	ENDIF

	RTS


;; Removes a single chain tile every REMOVE_CHAIN_FRAME_DELAY frames.
;; REGISTERS: 16 bit A, 16 bit Index, DB = $7E
;; INPUT: DP = EventStruct location
;; OUTPUT: c set if function continues next frame, c clear if this is the last frame.
.A16
.I16
ROUTINE RemoveChainEvent
	; if entity->frameDelay != 0
	;	entity->frameDelay--
	;	if entity->frameDelay & 1
	;		MetaTiles1x16__yPos += RATTLE_SCREEN_AMOUNT
	;	else
	;		MetaTiles1x16__yPos -= RATTLE_SCREEN_AMOUNT
	;	return true
	; else
	; 	entity->frameDelay = REMOVE_CHAIN_FRAME_DELAY
	;	// SOUND - remove chain
	;	MetaTiles1x16__mapDirty = 1
	;
	;	MetaTiles1x16__map[currentChainPieceToRemove] = 0
	;
	;	entity->currentChainPieceToRemove -= MetaTiles1x16__sizeOfMapRow
	;	if entity->currentChainPieceToRemove < 0
	;		return false
	;
	;	if MetaTiles1x16__map[currentChainPieceToRemove] != entity->chainTile
	;		return false
	;
	;	MetaTiles1x16__map[currentChainPieceToRemove] = entity->chainBottomTile
	;
	;	return true

	SEP	#$20
.A8
	LDA	z:EventStruct::frameDelay
	IF_NOT_ZERO
		LSR	; c = LSB of frameDelay
		DEC	z:EventStruct::frameDelay

		REP	#$20
.A16

		; rattle the screen - show something is happening
		.assert REMOVE_CHAIN_FRAME_DELAY & 1 = 0, error, "REMOVE_CHAIN_FRAME_DELAY must be even to rattle screen properly"

		LDA	MetaTiles1x16__yPos
		IF_C_CLEAR
			; a clear
			ADC	#RATTLE_SCREEN_AMOUNT
		ELSE
			; c already set
			SBC	#RATTLE_SCREEN_AMOUNT
		ENDIF
		STA	MetaTiles1x16__yPos

		SEC
		RTS	
	ENDIF
.A8

	LDA	#REMOVE_CHAIN_FRAME_DELAY
	STA	z:EventStruct::frameDelay

	; ::SOUND remove chain::

	LDA	#1
	STA	.loword(MetaTiles1x16__mapDirty)

	REP	#$30
.A16

	LDX	z:EventStruct::currentChainPieceToRemove
	STZ	.loword(MetaTiles1x16__map), X

	TXA
	SUB	MetaTiles1x16__sizeOfMapRow
	IF_MINUS
		CLC
		RTS
	ENDIF
	STA	z:EventStruct::currentChainPieceToRemove

	TAX
	LDA	.loword(MetaTiles1x16__map), X
	CMP	z:EventStruct::chainTile
	IF_NE
		CLC
		RTS
	ENDIF

	LDA	z:EventStruct::chainBottomTile
	STA	.loword(MetaTiles1x16__map), X

	SEC
	RTS

ENDMODULE

