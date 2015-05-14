
.include "npc-unmoving.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "../entities.h"
.include "../entity.h"
.include "../entity-physics.h"
.include "../gameloop.h"

.include "routines/metasprite.h"

ENTITY_WIDTH = 16
ENTITY_HEIGHT = 16
ENTITY_XOFFSET = 8
ENTITY_YOFFSET = 8

.define WES WalkAndTurnEntityStruct
ENTITY_PHYSICS_STRUCT WalkAndTurnEntityStruct
	;; If zero moving left, else right
	walkLeftOnZero		.word

	;; Number of pixels ahead of the entity to check before ledge
	ledgeCheckOffset	.word
END_ENTITY_PHYSICS_STRUCT


MODULE Npc_WalkAndTurn

.rodata
LABEL	FunctionsTable
	.addr	.loword(Init)
	.addr	.loword(Process)
	.addr	.loword(CollisionPlayer)


; DP = entity
; DB = $7E
; A = Number of pixels ahead of the entity to check before ledge. (If non zero)
.A16
.I16
ROUTINE Init
	IF_NOT_ZERO
		STA	z:WES::ledgeCheckOffset
	ENDIF
	RTS


; DP = entity
; DB = $7E
; OUT: c set if entity still alive
.A16
.I16
ROUTINE Process
	LDA	z:WES::walkLeftOnZero
	IF_ZERO
		LDA	#JOY_LEFT
	ELSE
		LDA	#JOY_RIGHT
	ENDIF

	JSR	EntityPhysics__MoveEntityWithController
	JSR	EntityPhysics__EntityPhysicsWithCollisions

	; Test if collide with wall
	; -------------------------

	SEP	#$20
.A8
	LDA	EntityPhysics__status
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

	; WalkAndTurnEntityStruct
LABEL	WalkLeft
	.word	WalkLeft_End - WalkLeft		; size
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
	.word	$0000				; walkLeftOnZero
	.word	8				; ledgeCheckOffset 
WalkLeft_End:


	; WalkAndTurnEntityStruct
LABEL	WalkRight
	.word	WalkRight_End - WalkRight	; size
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
	.word	$FFFF				; walkLeftOnZero
	.word	8				; ledgeCheckOffset 
WalkRight_End:


.segment "BANK1"

;; TEST example data::

ExampleMetaSpriteFrame:
	.byte	1
	.byte	.lobyte(-8)
	.byte	.lobyte(-8)
	.word	2 << OAM_CHARATTR_ORDER_SHIFT
	.byte	$FF

ENDMODULE

