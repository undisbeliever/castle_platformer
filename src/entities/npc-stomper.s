
.include "npc-stomper.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "../entities.h"
.include "../entity.h"
.include "../entity-physics.h"
.include "../entity-animation.h"
.include "../gameloop.h"

.include "routines/metasprite.h"

ENTITY_MAX_Y_VECL = $0400

.enum State
	WAITING = 0
	FALLING  = 2
	ON_GROUND  = 4
	RISING  = 6
.endenum

.define SES StomperEntityStruct


MODULE Npc_Stomper

.rodata
LABEL	FunctionsTable
	.addr	Init
	.addr	EntityAnimation__Activated
	.addr	EntityAnimation__Inactivated
	.addr	Process
	.addr	CollisionPlayer


.code

; DP = entity
; DB = $7E
.A16
.I16
ROUTINE Init
	LDA	z:SES::yPos + 1
	STA	z:SES::startingYpos

	STZ	z:SES::state

	RTS


; DP = entity
; DB = $7E
; OUT: c set if entity still alive
.A16
.I16
ROUTINE Process
	LDX	z:SES::state
	JMP	(.loword(ProcessTable), X)

.rodata
ProcessTable:
	.addr	Process_Waiting
	.addr	Process_Falling
	.addr	Process_OnGround
	.addr	Process_Rising


.code


.A16
.I16
ROUTINE Process_Waiting
	LDA	Entities__player + EntityStruct::xPos + 1
	SUB	z:SES::xPos + 1
	IF_MINUS
		NEG16
	ENDIF

	CMP	z:SES::threashold
	IF_LT
		LDX	#State::FALLING
		STX	z:SES::state

		LDA	#Npc_Stomper_AnimationId::FALLING
		JSR	EntityAnimation__SetAnimation
	ELSE
		LSR
		CMP	z:SES::threashold
		IF_LT
			LDA	#Npc_Stomper_AnimationId::NOTICED_PLAYER
		ELSE
			LDA	#Npc_Stomper_AnimationId::WAITING
		ENDIF

		JSR	EntityAnimation__SetAnimation
	ENDIF

	SEC
	RTS


.A16
.I16
ROUTINE Process_Falling
	JSR	EntityPhysics__EntityPhysicsWithCollisions

	LDA	EntityPhysics__status
	IF_BIT	#EntityPhysicsStatusBits::STANDING
		LDA	z:SES::raiseSpeed
		NEG16
		STA	z:SES::yVecl

		LDX	#State::ON_GROUND
		STX	z:SES::state

		LDA	#Npc_Stomper_AnimationId::ON_GROUND
		JSR	EntityAnimation__SetAnimation
	ENDIF

	SEC
	RTS



.A16
.I16
ROUTINE Process_OnGround
	JSR	EntityAnimation__IsAnimationStopped
	IF_Z_SET
		LDX	#State::RISING
		STX	z:SES::state

		LDA	#Npc_Stomper_AnimationId::RISING
		JSR	EntityAnimation__SetAnimation
	ENDIF

	SEC
	RTS



.A16
.I16
ROUTINE Process_Rising
	JSR	EntityPhysics__EntityPhysicsWithCollisionsNoGravity

	LDA	EntityPhysics__status
	BIT	#EntityPhysicsStatusBits::HEAD_COLLISION
	BNE	Process_Rising_Waiting

	LDA	z:SES::startingYpos
	CMP	z:SES::yPos + 1
	IF_GE
		STA	z:SES::yPos + 1

Process_Rising_Waiting:
		LDX	#State::WAITING
		STX	z:SES::state

		LDA	#Npc_Stomper_AnimationId::WAITING
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
	LDA	#GameState::DEAD
	STA	GameLoop__state

	LDA	#Npc_Stomper_AnimationId::COLLISION_PLAYER
	JSR	EntityAnimation__SetAnimation

	SEC
	RTS

ENDMODULE


