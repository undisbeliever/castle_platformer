
.include "removebridge.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "../camera.h"
.include "routines/background-events.h"
.include "routines/metatiles/metatiles-1x16.h"

EXTEND_BRIDGE_FRAME_DELAY = 4

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
	; Camera__shaking = true
	;
	; if event->frameDelay != 0
	;	event->frameDelay--
	;	return true
	; else
	; 	event->frameDelay = EXTEND_BRIDGE_FRAME_DELAY
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

	LDA	#EXTEND_BRIDGE_FRAME_DELAY
	STA	z:EventStruct::frameDelay

	; A = non-zero
	STA	.loword(MetaTiles1x16__mapDirty)

	REP	#$20
.A16

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

