
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

	RTS


; DP = player entity
.A16
.I16
ROUTINE Process
	LDA	Controller__current
	IF_BIT	#JOY_LEFT
		STZ	z:PES::facingLeftOnZero
	ELSE_BIT #JOY_RIGHT
		STA	z:PES::facingLeftOnZero
	ENDIF

	JSR	EntityPhysics__MoveEntityWithController

	JSR	EntityPhysics__EntityPhysicsWithCollisions

	; Player/tile interactions
	LDX	EntityPhysics__entityTouchTileFunctionPtr
	IF_NOT_ZERO
		JSR	(MetaTileFunctionsTable::PlayerTouch, X)
	ENDIF

	; reset enemies jumped on counter if on ground 
	.assert EntityPhysicsStatusBits::STANDING = $80, error, "Bad Value"
	LDA	EntityPhysics__status - 1
	IF_N_SET
		STZ	z:PES::nEnemysJumpedOnBeforeTouchingGround
	ENDIF

	; Animation
	; ---------
	.assert EntityPhysicsStatusBits::STANDING = $80, error, "Bad Value"
	LDA	EntityPhysics__status - 1
	IF_N_SET
		LDA	z:PES::facingLeftOnZero
		IF_ZERO
			; facing left
			LDA	z:PES::xVecl
			IF_ZERO
				LDA	#Player_AnimationId::STAND_LEFT
			ELSE
				IF_MINUS
					LDA	#Player_AnimationId::WALK_LEFT
				ELSE
					LDA	#Player_AnimationId::SLIDE_LEFT
				ENDIF
			ENDIF
		ELSE
			LDA	z:PES::xVecl
			IF_ZERO
				LDA	#Player_AnimationId::STAND_RIGHT
			ELSE
				IF_PLUS
					LDA	#Player_AnimationId::WALK_RIGHT
				ELSE
					LDA	#Player_AnimationId::SLIDE_RIGHT
				ENDIF
			ENDIF
		ENDIF
	ELSE
		LDA	z:PES::yVecl
		IF_MINUS
			; jumping
			LDA	#Player_AnimationId::JUMP_LEFT
			LDX	z:PES::facingLeftOnZero
			IF_NOT_ZERO
				INC
			ENDIF
		ELSE
			; falling
			LDA	#Player_AnimationId::FALL_LEFT
			LDX	z:PES::facingLeftOnZero
			IF_NOT_ZERO
				INC
			ENDIF
		ENDIF
	ENDIF

	JSR	EntityAnimation__SetAnimation


	; Interactive MetaTiles
	; ---------------------
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



; IN: DP - NPC
.A16
.I16
ROUTINE Kill
	PHD

	LDA	#player
	TCD

	LDA	#Player_AnimationId::DEAD
	JSR	EntityAnimation__SetAnimation

	LDA	#GameState::DEAD
	STA	GameLoop__state

	PLD
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

ENDMODULE

