
.include "removebridge.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "routines/background-events.h"
.include "routines/metatiles/metatiles-1x16.h"

REMOVE_CHAIN_FRAME_DELAY = 4
RATTLE_SCREEN_AMOUNT = 3

BACKGROUND_EVENT_STRUCT EventStruct
	frameDelay			.word
	currentBridgePieceToExtend	.addr
	bridgeTile			.word
	extendLeftOnZero		.word
END_BACKGROUND_EVENT_STRUCT


MODULE StandingEvents_ExtendBridge

.code

; IN: A - bridge location on map
; DP = entity
.A16
.I16
ROUTINE ExtendBridge
	; x = bridgeLocation
	; tile = MetaTiles1x16__map[bridgeLocation]
	;
	; if MetaTiles1x16__map[bridgeLocation - 2] == 0 || MetaTiles1x16__map[bridgeLocation + 2] == 0
	;	event = BackgroundEvents__NewEvent(ExtendBridgeEvent)
	;
	;	if event
	;		event->frameDelay = 0
	;		event->bridgeTile = MetaTiles1x16__map[bridgeLocation]
	;		if MetaTiles1x16__map[bridgeLocation - 2] = 0
	;			event->extendLeftOnZero = 0
	;			event->currentBridgePieceToExtend = bridgeLocation - 2
	;		else
	;			event->extendLeftOnZero = 1
	;			event->currentBridgePieceToExtend = bridgeLocation + 2

	TAX

	LDA	.loword(MetaTiles1x16__map - 2), X
	BEQ	_ExtendBridge

	LDA	.loword(MetaTiles1x16__map + 2), X
	IF_ZERO
_ExtendBridge:
		PHX

		LDX	#.loword(ExtendBridgeEvent)
		JSR	BackgroundEvents__NewEvent

		PLY
		IF_C_SET
			STZ	a:EventStruct::frameDelay, X

			LDA	.loword(MetaTiles1x16__map), Y
			STA	a:EventStruct::bridgeTile, X

			LDA	.loword(MetaTiles1x16__map - 2), Y
			IF_ZERO
				; extend left
				STZ	a:EventStruct::extendLeftOnZero, X
				TYA
				DEC
				DEC
			ELSE
				; extend right, A = non-zero
				STA	a:EventStruct::extendLeftOnZero, X
				TYA
				INC
				INC
			ENDIF

			STA	a:EventStruct::currentBridgePieceToExtend, X
		ENDIF
	ENDIF

	RTS


;; Extends a single bridge tile every frame
;; REGISTERS: 16 bit A, 16 bit Index, DB = $7E
;; INPUT: DP = EventStruct location
;; OUTPUT: c set if function continues next frame, c clear if this is the last frame.
.A16
.I16
ROUTINE ExtendBridgeEvent
	; if event->frameDelay != 0
	;	event->frameDelay--
	;	if event->frameDelay & 1
	;		MetaTiles1x16__yPos += RATTLE_SCREEN_AMOUNT
	;	else
	;		MetaTiles1x16__yPos -= RATTLE_SCREEN_AMOUNT
	;	return true
	; else
	; 	event->frameDelay = REMOVE_CHAIN_FRAME_DELAY
	;	// SOUND - remove chain
	;	MetaTiles1x16__mapDirty = 1
	;
	;	MetaTiles1x16__map[event->currentBridgePieceToExtend] = bridgeTile
	;
	;	if event->extendLeftOnZero == 0
	;		currentBridgePieceToExtend -= 2
	;	else
	;		currentBridgePieceToExtend += 2
	;
	;	if MetaTiles1x16__map[currentBridgePieceToExtend] != 0
	;		return false
	;
	;	return true

	LDA	z:EventStruct::frameDelay
	IF_NOT_ZERO
		LSR	; c = LSB of frameDelay
		DEC	z:EventStruct::frameDelay

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

	LDA	#REMOVE_CHAIN_FRAME_DELAY
	STA	z:EventStruct::frameDelay

	; ::SOUND extend bridge::

	LDA	#1
	STA	.loword(MetaTiles1x16__mapDirty)

	LDX	z:EventStruct::currentBridgePieceToExtend
	LDA	z:EventStruct::bridgeTile
	STA	.loword(MetaTiles1x16__map), X

	LDA	z:EventStruct::extendLeftOnZero
	IF_ZERO
		DEX
		DEX
	ELSE
		INX
		INX
	ENDIF
	STX	z:EventStruct::currentBridgePieceToExtend

	LDA	.loword(MetaTiles1x16__map), X
	IF_NOT_ZERO
		CLC
		RTS
	ENDIF

	SEC
	RTS

ENDMODULE

