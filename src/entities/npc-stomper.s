
.include "npc-stomper.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "../entities.h"
.include "../entity.h"
.include "../entity-physics.h"
.include "../gameloop.h"

.include "routines/metasprite.h"

ENTITY_MAX_Y_VECL = $0400

ENTITY_WIDTH = 32
ENTITY_HEIGHT = 32
ENTITY_XOFFSET = 16
ENTITY_YOFFSET = 16

.enum States
	FLOATING = 0
	FALLING  = 2
	WAITING  = 4
	RAISING  = 6
.endenum

.define SES StomperEntityStruct
ENTITY_PHYSICS_STRUCT StomperEntityStruct
	;; The number of pixels from the entity to the player before stomping.
	threashold		.word

	;; The number of frames to wait before raising.
	stompDelay		.word

	;; The speed in which the entity raises
	;; 1:7:8 signed fixed point. (1/256 pixels/frame)
	raiseSpeed		.word

	;  The fields below do not need to be set initialized.
	; -----------------------------------------------------

	;; Origional starting height
	startingYpos		.word

	;; Entity state.
	state			.word

	;; Current counter for the wait state
	frameWait		.word
END_ENTITY_PHYSICS_STRUCT


MODULE Npc_Stomper

.rodata
LABEL	FunctionsTable
	.addr	.loword(Init)
	.addr	.loword(Process)
	.addr	.loword(CollisionPlayer)


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
	.addr	Process_Floating
	.addr	Process_Falling
	.addr	Process_Waiting
	.addr	Process_Raising


.code


.A16
.I16
ROUTINE Process_Floating
	LDA	Entities__player + EntityStruct::xPos + 1
	SUB	z:SES::xPos + 1
	IF_MINUS
		NEG16
	ENDIF

	CMP	z:SES::threashold
	IF_LT
		LDX	#States::FALLING
		STX	z:SES::state
	ENDIF

	SEC
	RTS


.A16
.I16
ROUTINE Process_Falling
	JSR	EntityPhysics__EntityPhysicsWithCollisions

	LDA	EntityPhysics__status
	IF_BIT	#EntityPhysicsStatusBits::STANDING
		LDA	z:SES::stompDelay
		STA	z:SES::frameWait

		LDA	z:SES::raiseSpeed
		NEG16
		STA	z:SES::yVecl

		LDX	#States::WAITING
		STX	z:SES::state
	ENDIF

	SEC
	RTS



.A16
.I16
ROUTINE Process_Waiting
	DEC	z:SES::frameWait
	IF_ZERO
		LDX	#States::RAISING
		STX	z:SES::state
	ENDIF

	SEC
	RTS



.A16
.I16
ROUTINE Process_Raising
	JSR	EntityPhysics__EntityPhysicsWithCollisionsNoGravity

	LDA	EntityPhysics__status
	IF_BIT	#EntityPhysicsStatusBits::HEAD_COLLISION
		LDX	#States::FLOATING
		STX	z:SES::state
	ELSE
		LDA	z:SES::startingYpos
		CMP	z:SES::yPos + 1
		IF_GE
			STA	z:SES::yPos + 1

			LDX	#States::FLOATING
			STX	z:SES::state
		ENDIF
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

	SEC
	RTS


.segment ENTITY_STATE_BANK

	; StomperEntityStruct
LABEL	InitState
	.word	InitState_End - InitState	; size
	.addr	.loword(FunctionsTable)		; functionsTable
	.byte	0, 0, 0				; xPos
	.byte	0, 0, 0				; yPos
	.word	ENTITY_WIDTH			; size_width
	.word	ENTITY_HEIGHT			; size_height
	.word	ENTITY_XOFFSET			; size_xOffset
	.word	ENTITY_YOFFSET			; size_yOffset
	.addr	.loword(ExampleMetaSpriteFrame)	; metaSpriteFrame
	.word	0				; metaSpriteCharAttr
	.word	0				; xVecl
	.word	0				; yVecl
	.addr	0				; standingTile
	.addr	0				; currentTileProperty
	.word	48				; threashold (pixels)
	.word	20				; stompDelay
	.word	192				; raiseSpeed (in 1/256 pixels/frame)
InitState_End:


.segment "BANK1"

;; TEST example data::

ExampleMetaSpriteFrame:
	.byte	4
	.byte	.lobyte(-16)
	.byte	.lobyte(-16)
	.word	2 << OAM_CHARATTR_ORDER_SHIFT
	.byte	$FF
	.byte	.lobyte(-16)
	.byte	.lobyte(0)
	.word	2 << OAM_CHARATTR_ORDER_SHIFT
	.byte	$FF
	.byte	.lobyte(0)
	.byte	.lobyte(-16)
	.word	2 << OAM_CHARATTR_ORDER_SHIFT
	.byte	$FF
	.byte	.lobyte(0)
	.byte	.lobyte(0)
	.word	2 << OAM_CHARATTR_ORDER_SHIFT
	.byte	$FF

ENDMODULE


