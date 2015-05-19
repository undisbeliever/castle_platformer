
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
		LDA	#GameState::DEAD
		STA	GameLoop__state
	ENDIF

	RTS

ENDMODULE

