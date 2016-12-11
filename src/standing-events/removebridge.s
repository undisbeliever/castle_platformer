
.include "removebridge.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "../camera.h"
.include "routines/background-events.h"
.include "routines/metatiles/metatiles-1x16.h"

BACKGROUND_EVENT_STRUCT EventStruct
	currentBridgePieceToRemove	.addr
	bridgeTile			.word
END_BACKGROUND_EVENT_STRUCT


MODULE StandingEvents_RemoveBridge

.code

; IN: A - bridge location on map
; DP = entity
.A16
.I16
ROUTINE RemoveBridge
	; x = bridgeLocation
	; tile = MetaTiles1x16__map[bridgeLocation]
	; if tile != 0
	;	entity = BackgroundEvents__NewEvent(RemoveBridgeEvent)
	;	if entity
	;		currentBridgePieceToRemove = bridgeLocation
	;		entity->bridgeTile = MetaTiles1x16__map[bridgeLocation]

	TAX

	; Check if bridge already removed, and setup callback.
	LDA	.loword(MetaTiles1x16__map), X
	IF_NOT_ZERO
		PHX

		LDX	#.loword(RemoveBridgeEvent)
		JSR	BackgroundEvents__NewEvent

		PLA
		IF_C_SET
			STA	a:EventStruct::currentBridgePieceToRemove, X
			TAY
			LDA	.loword(MetaTiles1x16__map), Y
			STA	a:EventStruct::bridgeTile, X
		ENDIF
	ENDIF

	RTS


;; Removes a single bridge tile every frame
;; REGISTERS: 16 bit A, 16 bit Index, DB = $7E
;; INPUT: DP = EventStruct location
;; OUTPUT: c set if function continues next frame, c clear if this is the last frame.
.A16
.I16
ROUTINE RemoveBridgeEvent
	; Camera__shaking = 1
	; MetaTiles1x16__mapDirty = 1
	;
	; MetaTiles1x16__map[event->currentBridgePieceToRemove] = 0
	;
	; event->currentBridgePieceToRemove++ // actualy + 2
	;
	; if MetaTiles1x16__map[event->currentBridgePieceToRemove] != event->bridgeTile
	; 	return false
	;
	; return true

	SEP	#$20
.A8
	LDA	#1
	STA	Camera__shaking
	STA	.loword(MetaTiles1x16__mapDirty)

	REP	#$20
.A16

	LDX	z:EventStruct::currentBridgePieceToRemove
	STZ	.loword(MetaTiles1x16__map), X

	INX
	INX
	STX	z:EventStruct::currentBridgePieceToRemove

	LDA	.loword(MetaTiles1x16__map), X
	CMP	z:EventStruct::bridgeTile
	IF_NE
		CLC
		RTS
	ENDIF

	SEC
	RTS

ENDMODULE

