
.include "npc-bat.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "player.h"
.include "../entities.h"
.include "../entity.h"
.include "../entity-physics.h"
.include "../entity-animation.h"


.include "routines/metasprite.h"

.enum State
	HOVER	    = 0
	FLYING      = 2
.endenum

.define BES BatEntityStruct


MODULE Npc_Bat

.rodata
LABEL	FunctionsTable
	.addr	Init
	.addr	Activated
	.addr	EntityAnimation__Inactivated
	.addr	Process
	.addr	CollisionPlayer


.code

; DP = entity
; DB = $7E
.A16
.I16
ROUTINE Init

	IF_NOT_ZERO
		STA	z:BES::threashold
	ENDIF

	STZ	z:BES::state

	LDA	z:BES::hoverHeight
	LSR
	STA	z:BES::hoverPosition

	STZ	z:BES::hoverUpOnZero

	RTS


; DP = entity
; DB = $7E
; OUT: c set if entity still alive
.A16
.I16
ROUTINE Process
	LDX	z:BES::state
	JMP	(.loword(ProcessTable), X)

.rodata
ProcessTable:
	.addr	Process_Hover
	.addr	Process_Flying


.code

.A16
.I16
ROUTINE Activated
	STZ	z:BES::state
	STZ	z:BES::xVecl

	JMP	EntityAnimation__Activated


.A16
.I16
ROUTINE Process_Hover

	LDA	z:BES::hoverUpOnZero
	IF_ZERO
		; Hovering Upwards
		LDA	z:BES::hoverYVecl
		STA	z:BES::yVecl

		RSB16	z:BES::hoverPosition
		IF_MINUS
			; A is non-zero
			STA	z:BES::hoverUpOnZero

			LDA	z:BES::hoverHeight
		ENDIF

		STA	z:BES::hoverPosition
	ELSE
		; Hovering Downwards

		LDA	z:BES::hoverYVecl
		NEG16
		STA	z:BES::yVecl

		LDA	z:BES::hoverPosition
		SUB	z:BES::hoverYVecl
		IF_MINUS
			STZ	z:BES::hoverUpOnZero
			LDA	z:BES::hoverHeight
		ENDIF

		STA	z:BES::hoverPosition
	ENDIF

	JSR	EntityPhysics__EntityPhysicsWithCollisionsNoGravity


	; Determine if facing player.
	.assert Npc_Bat_AnimationId::FLY_LEFT <> 0, error, "Bad value"

	LDA	#Npc_Bat_AnimationId::HOVER_LEFT

	LDX	z:BES::xPos + 1
	CPX	Entities__player + EntityStruct::xPos + 1
	IF_GE
		STZ	z:BES::flyLeftOnZero
	ELSE
		LDX	#1
		STX	z:BES::flyLeftOnZero
		INC
	ENDIF

	JSR	EntityAnimation__SetAnimation

	LDA	Entities__player + EntityStruct::yPos + 1
	SUB	z:BES::yPos + 1
	IF_MINUS
		NEG16
	ENDIF

	CMP	z:BES::threashold
	IF_LT
		LDX	#State::FLYING
		STX	z:BES::state

		LDA	#Npc_Bat_AnimationId::FLY_LEFT
		LDX	z:BES::flyLeftOnZero
		IF_NOT_ZERO
			INC
		ENDIF
		JSR	EntityAnimation__SetAnimation
	ENDIF

	SEC
	RTS


.A16
.I16
ROUTINE Process_Flying
	LDA	z:BES::flyXVecl
	LDX	z:BES::flyLeftOnZero
	IF_ZERO
		NEG16
	ENDIF
	STA	z:BES::xVecl
	STZ	z:BES::yVecl

	JSR	EntityPhysics__EntityPhysicsWithCollisionsNoGravity

	LDA	EntityPhysics__status
	IF_BIT	#EntityPhysicsStatusBits::LEFT_COLLISION | EntityPhysicsStatusBits::RIGHT_COLLISION

		LDX	z:BES::flyLeftOnZero
		IF_ZERO
			DEX
			LDA	#Npc_Bat_AnimationId::FLY_RIGHT
		ELSE
			LDX	#0
			LDA	#Npc_Bat_AnimationId::FLY_LEFT
		ENDIF

		STX	z:BES::flyLeftOnZero
		JSR	EntityAnimation__SetAnimation
	ENDIF

	SEC
	RTS


; DP = entity
; DB = $7E
; OUT: c set if entity still alive
.A16
.I16
ROUTINE	CollisionPlayer
	LDA	#Npc_Bat_AnimationId::COLLISION_PLAYER
	JSR	EntityAnimation__SetAnimation

	JSR	Player__Kill

	SEC
	RTS

ENDMODULE


