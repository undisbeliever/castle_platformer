
.include "removechain.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "../camera.h"
.include "routines/background-events.h"
.include "routines/metatiles/metatiles-1x16.h"

REMOVE_CHAIN_FRAME_DELAY = 6

BACKGROUND_EVENT_STRUCT EventStruct
	frameDelay			.word
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

			; ensure chain is removed immediately, safe to write in 16 bit mode
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
	; camera__shaking = true
	;
	; if entity->frameDelay != 0
	;	entity->frameDelay--
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

	LDA	#1
	STA	Camera__shaking

	LDA	z:EventStruct::frameDelay
	IF_NOT_ZERO
		DEC	z:EventStruct::frameDelay

		REP	#$20
.A16
		SEC
		RTS	
	ENDIF
.A8

	; ::SOUND remove chain::

	LDA	#REMOVE_CHAIN_FRAME_DELAY
	STA	z:EventStruct::frameDelay

	; A = non-zero
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

