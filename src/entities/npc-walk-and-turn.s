
.include "npc-walk-and-turn.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "player.h"
.include "../entities.h"
.include "../entity.h"
.include "../entity-animation.h"
.include "../entity-physics.h"
.include "../gameloop.h"

.include "routines/metasprite.h"

.define WES WalkAndTurnEntityStruct
.define player Entities__player



MODULE Npc_WalkAndTurn

.rodata
LABEL	FunctionsTable
	.addr	Init
	.addr	EntityAnimation__Activated
	.addr	EntityAnimation__Inactivated
	.addr	Process
	.addr	CollisionPlayer


.enum State
	WALKING			= 0
	FALLING 		= 2
	WAIT_FOR_ANIMATION_END	= 4
	DEATH_ANIMATION		= 6
.endenum

.code

; DP = entity
; DB = $7E
; A = Number of pixels ahead of the entity to check before ledge. (If non zero)
.A16
.I16
ROUTINE Init
	IF_NOT_ZERO
		STA	z:WES::ledgeCheckOffset
	ENDIF

	.assert State::WALKING = 0, error, "Bad code"
	STZ	z:WES::state

	RTS


; DP = entity
; DB = $7E
; OUT: c set if entity still alive
.A16
.I16
ROUTINE Process
	LDX	z:WES::state
	JMP	(.loword(ProcessFunctionTable), X)

.rodata
ProcessFunctionTable:
	.addr	Process_Walking
	.addr	Process_Falling
	.addr	Process_WaitForAnimationEnd
	.addr	Process_DeathAnimation
.code


; DP = entity
; OUT: C set if entity still alive
.A16
.I16
ROUTINE Process_Walking
	LDA	z:WES::walkLeftOnZero
	IF_ZERO
		LDA	#JOY_LEFT
	ELSE
		LDA	#JOY_RIGHT
	ENDIF

	JSR	EntityPhysics__MoveEntityWithController
	JSR	EntityPhysics__EntityPhysicsWithCollisions

	; Test if now falling
	; -------------------

	SEP	#$20
.A8
	LDA	EntityPhysics__status
	.assert EntityPhysicsStatusBits::STANDING = $80, error, "Bad Code"
	IF_N_CLEAR
		; Entity is falling
		;  - set state to falling
		;  - set Animation to falling

		LDX	#State::FALLING
		STX	z:WES::state

		LDA	#Npc_WalkAndTurn_AnimationId::FALL_LEFT

		LDX	z:WES::walkLeftOnZero
		IF_NOT_ZERO
			INC
		ENDIF

		REP	#$30
		JSR	EntityAnimation__SetAnimation
		SEC
		RTS
	ENDIF


	; Test if collide with wall
	; -------------------------
.A8
	; A = EntityPhysics__status
	IF_BIT	#EntityPhysicsStatusBits::LEFT_COLLISION
		; non-zero A
		STA	z:WES::walkLeftOnZero

	ELSE_BIT #EntityPhysicsStatusBits::RIGHT_COLLISION
		STZ	z:WES::walkLeftOnZero
	ENDIF

	REP	#$20
.A16

	; Test if about to fall off edge
	; ------------------------------

	; if walkLeftOnZero == 0:
	; 	x = wes->xPos - wes->size_xOffset - wes->ledgeCheckOffset
	; else:
	; 	x = wes->xPos - wes->size_xOffset + wes->size_height + wes->ledgeCheckOffset
	; y = wes->yPos - wes->size_yOffset + wes->size_height
	; pos = MetaTiles1x16__LocationToTilePos(x, y)
	;
	; tileProperty = EntityPhysics__metaTilePropertyTable[MetaTiles1x16__map[pos]]
	;
	; if MetaTilePropertyBank[tileProperty]->type == 0:
	; 	wes->walkLeftOnZero = ! wes->walkLeftOnZero

	LDA	z:WES::xPos + 1
	SUB	z:WES::size_xOffset

	LDY	z:WES::walkLeftOnZero
	IF_ZERO
		; left
		SUB	z:WES::ledgeCheckOffset
	ELSE
		; right
		ADD	z:WES::size_width
		ADC	z:WES::ledgeCheckOffset
	ENDIF

	TAX

	LDA	z:WES::yPos + 1
	SUB	z:WES::size_yOffset
	ADD	z:WES::size_height
	TAY
	JSR	MetaTiles1x16__LocationToTilePos

	TAY
	LDX	a:MetaTiles1x16__map, Y
	LDA	EntityPhysics__metaTilePropertyTable, X
	TAX

	LDA	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::type, X
	IF_ZERO
		LDA	z:WES::walkLeftOnZero
		IF_ZERO
			DEC
			STA	z:WES::walkLeftOnZero
		ELSE
			STZ	z:WES::walkLeftOnZero
		ENDIF
	ENDIF

	; Set Animation
	; -------------
	LDA	z:WES::walkLeftOnZero
	IF_ZERO
		LDA	z:WES::xVecl
		IF_MINUS
			LDA	#Npc_WalkAndTurn_AnimationId::WALK_LEFT
		ELSE
			LDA	#Npc_WalkAndTurn_AnimationId::SLIDE_LEFT
		ENDIF
	ELSE
		LDA	z:WES::xVecl
		IF_PLUS
			LDA	#Npc_WalkAndTurn_AnimationId::WALK_RIGHT
		ELSE
			LDA	#Npc_WalkAndTurn_AnimationId::SLIDE_RIGHT
		ENDIF
	ENDIF
	JSR	EntityAnimation__SetAnimation

	SEC
	RTS



; DP = entity
; OUT: C set if entity still alive
.A16
.I16
ROUTINE Process_Falling
	JSR	EntityPhysics__EntityPhysicsWithCollisions

	.assert EntityPhysicsStatusBits::STANDING = $80, error, "Bad Code"
	LDA	EntityPhysics__status - 1
	IF_N_SET
		; Landed on ground

		LDX	#State::WAIT_FOR_ANIMATION_END
		STX	z:WES::state

		LDA	#Npc_WalkAndTurn_AnimationId::LAND_LEFT

		LDX	z:WES::walkLeftOnZero
		IF_NOT_ZERO
			INC
		ENDIF
		JSR	EntityAnimation__SetAnimation
	ENDIF

	SEC
	RTS



; DP = Entity
; OUT: C set if entity still alive
.A16
.I16
ROUTINE Process_WaitForAnimationEnd
	JSR	EntityPhysics__EntityPhysicsWithCollisions

	JSR	EntityAnimation__IsAnimationStopped
	IF_Z_SET
		LDX	#State::WALKING
		STX	z:WES::state
	ENDIF

	SEC
	RTS



; DP = Entity
; OUT: C clear if entity dead
.A16
.I16
ROUTINE Process_DeathAnimation
	JSR	EntityAnimation__IsAnimationStopped
	IF_Z_SET
		CLC
	ELSE
		SEC
	ENDIF

	RTS




; DP = entity
; DB = $7E
; OUT: c set if entity still alive
.A16
.I16
ROUTINE	CollisionPlayer
	LDX	z:WES::state
	CPX	#State::DEATH_ANIMATION
	IF_NE
		LDA	z:WES::invincible
		AND	#$00FF
		IF_NOT_ZERO
			SEC
			BRA	_CollisionPlayerDead
		ENDIF

		JSR	Player__TestCollisionIsJumpingOnANpc
		IF_C_SET
_CollisionPlayerDead:
			; Entity not squished, kill player
			JSR	Player__Kill

			LDA	#State::WAIT_FOR_ANIMATION_END
			STA	z:WES::state

			LDA	#Npc_WalkAndTurn_AnimationId::COLLISION_HURT_PLAYER_LEFT
			LDX	z:WES::walkLeftOnZero
			IF_NOT_ZERO
				INC
			ENDIF
			JSR	EntityAnimation__SetAnimation
		ELSE
			; Entity has been squished
			; ::TODO find a nicer way to do this::
			; ::: Moving the entity into a nother list Perhaps?::

			LDX	#State::DEATH_ANIMATION
			STX	z:WES::state

			LDA	#Npc_WalkAndTurn_AnimationId::DEATH_ANIMATION_LEFT
			LDX	z:WES::walkLeftOnZero
			IF_NOT_ZERO
				INC
			ENDIF
			JSR	EntityAnimation__SetAnimation
		ENDIF
	ENDIF

	SEC
	RTS


ENDMODULE

