
.include "player.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "../entities.h"
.include "../entity.h"
.include "../entity-animation.h"
.include "../entity-physics.h"
.include "../controller.h"
.include "../gameloop.h"

.include "routines/block.h"
.include "routines/metasprite.h"
.include "routines/metatiles/metatiles-1x16.h"

; ::TODO move somewhere else
SCREEN_LEFT_RIGHT_SPACING = 95
SCREEN_UP_DOWN_SPACING = 65

; ::TODO move somewhere else

JUMP_ON_NPC_VELOCITY = $0250

ENTITY_WIDTH = 16
ENTITY_HEIGHT = 24
ENTITY_XOFFSET = 8
ENTITY_YOFFSET = 16

.define PES PlayerEntityStruct


MODULE Player
	SAME_VARIABLE player, Entities__player

.segment "WRAM7E"

.rodata
LABEL	FunctionsTable
	.addr	Init
	.addr	EntityAnimation__Activated
	.addr	EntityAnimation__Inactivated
	.addr	Process

.code


; DP = entity
.A8
.I16
ROUTINE Init
	STZ	z:PES::nEnemysJumpedOnBeforeTouchingGround

	; ::TODO dynamicaly load player tiles and palette::
	SEP	#$20
.A8
	PHB
	PHK
	PLB
	TransferToVramLocation	ExampleObjectTiles,	GAMELOOP_OAM_TILES
	TransferToCgramLocation	ExampleObjectPalette,	128 + 7 * 16

	LDX	#7 << OAM_CHARATTR_PALETTE_SHIFT
	STX	z:PES::metaSpriteCharAttr

	REP	#$20
.A16
	PLB
	RTS


; DP = player entity
.A16
.I16
ROUTINE Process
	LDA	Controller__current
	JSR	EntityPhysics__MoveEntityWithController

	JSR	EntityPhysics__EntityPhysicsWithCollisions

	; Player/tile interactions
	LDX	EntityPhysics__entityTouchTileFunctionPtr
	IF_NOT_ZERO
		JSR	(MetaTileFunctionsTable::PlayerTouch, X)
	ENDIF

	; reset enmies jumped on counter if on ground 
	.assert EntityPhysicsStatusBits::STANDING = $80, error, "Bad Value"
	LDA	EntityPhysics__status - 1
	IF_N_SET
		STZ	z:PES::nEnemysJumpedOnBeforeTouchingGround
	ENDIF

	LDY	z:PES::standingTile
	IF_NOT_ZERO
		LDX	z:PES::currentTileProperty
		LDA	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::functionsTable, X
		IF_NOT_ZERO
			TAX
			JMP	(MetaTileFunctionsTable::PlayerStand, X)
		ENDIF
	ENDIF

	; only here if there is no standing tile.

	RTS


; INTERACTION ROUTINES
; ====================

; IN: dp - NPC
; OUT: Carry set if NPC is NOT jumped on, Carry clear if enemy jumped on.
.A16
.I16
ROUTINE TestCollisionIsJumpingOnANpc
	; if player.yVecl >= 0 OR player.nEnemysJumpedOnBeforeTouchingGround >= 0
	;	if player.bottom < npc->yPos
	;		Player.yVecl = - JUMP_ON_NPC_VELOCITY
	;		player.nEnemysJumpedOnBeforeTouchingGround++
	;		return false
	; 
	; GameLoop__state = GameState::DEAD
	; return true

	; It's possibly to jump on two NPCs in a single frame.
	; Test to see if the jump is from the ground or not.
	LDA	player + PES::nEnemysJumpedOnBeforeTouchingGround
	BNE	_ContinueJumpingOnNPC

	; Testing y Velocity to ensure that player is not jumping
	; sideway into the hitbox.
	LDA	player + PES::yVecl
	IF_PLUS
_ContinueJumpingOnNPC:
		LDA	player + PES::yPos + 1
		SUB	player + PES::size_yOffset
		ADD	player + PES::size_height

		CMP	z:EntityStruct::yPos + 1
		IF_LT
			LDA	#.loword(-JUMP_ON_NPC_VELOCITY)
			STA	player + PES::yVecl

			INC	player + PES::nEnemysJumpedOnBeforeTouchingGround

			CLC
			RTS
		ENDIF
	ENDIF

	SEC
	RTS


.A16
.I16
ROUTINE	SetScreenPosition
	LDA	z:PES::xPos + 1
	SUB	MetaTiles1x16__xPos
	CMP	#256 - SCREEN_LEFT_RIGHT_SPACING
	IF_SGE
		LDA	z:PES::xPos + 1
		SUB	#256 - SCREEN_LEFT_RIGHT_SPACING
		CMP	MetaTiles1x16__maxXPos
		IF_GE
			LDA	MetaTiles1x16__maxXPos
		ENDIF
		STA	MetaTiles1x16__xPos
	ELSE
		CMP	#SCREEN_LEFT_RIGHT_SPACING
		IF_SLT
			LDA	z:PES::xPos + 1
			SUB	#SCREEN_LEFT_RIGHT_SPACING
			IF_MINUS
				LDA	#0
			ENDIF
			STA	MetaTiles1x16__xPos
		ENDIF
	ENDIF

	LDA	z:PES::yPos + 1
	SUB	MetaTiles1x16__yPos
	CMP	#224 - SCREEN_UP_DOWN_SPACING
	IF_SGE
		LDA	z:PES::yPos + 1
		SUB	#224 - SCREEN_UP_DOWN_SPACING
		CMP	MetaTiles1x16__maxYPos
		IF_GE
			LDA	MetaTiles1x16__maxYPos
		ENDIF
		STA	MetaTiles1x16__yPos
	ELSE
		CMP	#SCREEN_UP_DOWN_SPACING
		IF_SLT
			LDA	z:PES::yPos + 1
			SUB	#SCREEN_UP_DOWN_SPACING
			IF_MINUS
				LDA	#0
			ENDIF
			STA	MetaTiles1x16__yPos
		ENDIF
	ENDIF

	RTS


.segment ENTITY_STATE_BANK

LABEL	InitState
	.word	InitState_End - InitState	; size
	.addr	.loword(FunctionsTable)		; functionsTable
	.byte	0, 0, 0				; xPos
	.byte	0, 0, 0				; yPos
	.word	ENTITY_WIDTH			; size_width
	.word	ENTITY_HEIGHT			; size_height
	.word	ENTITY_XOFFSET			; size_xOffset
	.word	ENTITY_YOFFSET			; size_yOffset
	.word	.loword(ExampleMetaSpriteFrame)	; metaSpriteFrame 
	.word	0				; metaSpriteCharAttr
	.addr	0				; animationTable
	.addr	0				; animationPC
	.word	0				; tileVramLocation
	.byte	0				; animationFrameDelay
	.byte	$FF				; animationId
	.word	0				; xVecl
	.word	0				; yVecl
	.addr	0				; standingTile
	.addr	0				; currentTileProperty
InitState_End:


.segment "BANK1"

;; TEST example data::

.export MetaSpriteLayoutBank = .bankbyte(*)

ExampleMetaSpriteFrame:
	.byte	3
	.byte	.lobyte(-8)
	.byte	.lobyte(-8)
	.word	3 << OAM_CHARATTR_ORDER_SHIFT
	.byte	$FF
	.byte	.lobyte(-8)
	.byte	.lobyte(-16)
	.word	3 << OAM_CHARATTR_ORDER_SHIFT
	.byte	$00
	.byte	.lobyte(0)
	.byte	.lobyte(-16)
	.word	3 << OAM_CHARATTR_ORDER_SHIFT
	.byte	$00


ExampleObjectTiles:
	.repeat 32 * 32
		.byte	$FF
	.endrepeat
ExampleObjectTiles_End:

ExampleObjectPalette:
	.repeat	16
		.word	$FFFF
	.endrepeat
ExampleObjectPalette_End:

ENDMODULE

