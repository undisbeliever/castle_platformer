
.include "removebridge.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "routines/metatiles/metatiles-1x16.h"

RATTLE_SCREEN_AMOUNT = 3


MODULE	StandingEvents_RemoveBridge

.segment "WRAM7E"
	ADDR	currentBridgePieceToRemove
	WORD	bridgeTile
.code

; ::TODO redo, maybe I should allocate some DP space for the functions?::
; ::: That way I don't have to space the tiles so far apart?::
.global GameLoop__execOncePerFrame

; IN: A - bridge location on map
; DP = entity
.A16
.I16
ROUTINE RemoveBridge
	; x = bridgeLocation
	; tile = MetaTiles1x16__map[x]
	; if tile != 0
	;	bridgeTile = tile
	;	currentBridgePieceToRemove = x
	;
	;	GameLoop__execOncePerFrame = RemoveBridgeTimerCallback
	TAX

	; Check if bridge already removed, and setup callback.
	LDA	.loword(MetaTiles1x16__map), X
	IF_NOT_ZERO
		STA	bridgeTile
		STX	currentBridgePieceToRemove

		; ::TODO redo this bit, probably use DP allocation like Entities?::

		LDX	#.loword(RemoveBridgeTimer)
		STX	GameLoop__execOncePerFrame
	ENDIF

	RTS


;; Removes a single bridge tile every frame
;; REGISTERS: 16 bit A, 16 bit Index, DB = $7E, DP = 0
;; OUTPUT: c set if function continues next frame, c clear if this is the last frame.
.A16
.I16
ROUTINE RemoveBridgeTimer
	; if currentBridgePieceToRemove & 2 != 0
	;	MetaTiles1x16__yPos += RATTLE_SCREEN_AMOUNT
	; else
	;	MetaTiles1x16__yPos -= RATTLE_SCREEN_AMOUNT
	;
	; 	frameDelay = REMOVE_BRIDGE_FRAME_DELAY
	; // SOUND - remove bridge
	; MetaTiles1x16__mapDirty = 1
	;
	; MetaTiles1x16__map[currentBridgePieceToRemove] = 0
	;
	; currentBridgePieceToRemove++ // actualy + 2
	;
	; if MetaTiles1x16__map[currentBridgePieceToRemove] != bridgeTile
	; 	return false
	;
	; return true

	; rattle the screen - show something is happening
	LDA	currentBridgePieceToRemove
	IF_BIT	#2
		LDA	MetaTiles1x16__yPos
		ADD	#RATTLE_SCREEN_AMOUNT
	ELSE
		LDA	MetaTiles1x16__yPos
		SBC	#RATTLE_SCREEN_AMOUNT
	ENDIF
	STA	MetaTiles1x16__yPos

	; ::SOUND remove bridge::

	LDA	#1
	STA	.loword(MetaTiles1x16__mapDirty)

	REP	#$30
.A16

	LDX	currentBridgePieceToRemove
	STZ	.loword(MetaTiles1x16__map), X

	INX
	INX
	STX	currentBridgePieceToRemove

	LDA	.loword(MetaTiles1x16__map), X
	CMP	bridgeTile
	IF_NE
		CLC
		RTS
	ENDIF

	SEC
	RTS

ENDMODULE

