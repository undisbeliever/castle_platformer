
.include "physics.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "entities.h"
.include "metatileproperties.h"

.include "routines/block.h"
.include "routines/math.h"
.include "routines/metasprite.h"
.include "routines/metatiles/metatiles-1x16.h"

METATILES_SIZE = 16

;; Maximum Y velocity (prevents fall through walls)
MAX_Y_VECLOCITY = 10 * 256

; ::TODO move somewhere else

ENTITY_WIDTH = 16
ENTITY_HEIGHT = 24
ENTITY_XOFFSET = 8
ENTITY_YOFFSET = 16

MODULE Physics

.segment "WRAM7E"
	ADDR	metaTilePropertyTable, N_METATILES
	WORD	gravity

	ADDR	entityTouchTileFunctionPtr

	WORD	counter
.code


; A = Joypad Controls.
; DP = Entity
.A16
.I16
ROUTINE MoveEntityWithController
	PHA

	LDX	z:EntityStruct::currentTileProperty

	IF_BIT	#JOY_LEFT
		LDA	z:EntityStruct::xVecl
		SUB	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::walkAcceleration, X
		CMP	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::minimumXVelocity, X
		IF_SLT
			LDA	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::minimumXVelocity, X
		ENDIF
		STA	z:EntityStruct::xVecl

	ELSE_BIT #JOY_RIGHT
		LDA	z:EntityStruct::xVecl
		ADD	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::walkAcceleration, X
		CMP	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::maximumXVelocity, X
		IF_SGE
			LDA	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::maximumXVelocity, X
		ENDIF
		STA	z:EntityStruct::xVecl
	ENDIF

	PLA

	; Jump only if standing.
	LDY	z:EntityStruct::standingTile
	IF_NOT_ZERO
		IF_BIT	#JOY_B
			LDX	z:EntityStruct::currentTileProperty
			LDA	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::jumpingVelocity, X
			IF_NOT_ZERO
				STA	z:EntityStruct::yVecl
			ENDIF
		ENDIF
	ENDIF

	RTS



; ZP = Entity
.A16
.I16
ROUTINE EntityPhysicsWithCollisions

	LDA	z:EntityStruct::yVecl
	ADD	gravity
	IF_MINUS
		CMP	#.loword(-MAX_Y_VECLOCITY)
		IF_SLT
			LDA	#.loword(-MAX_Y_VECLOCITY)
		ENDIF
	ELSE
		CMP	#MAX_Y_VECLOCITY + 1
		IF_SGE
			LDA	#MAX_Y_VECLOCITY
		ENDIF
	ENDIF
	STA	z:EntityStruct::yVecl

	.assert * = EntityPhysicsWithCollisionsNoGravity, lderror, "Bad Flow"



; ZP = Entity
.A16
.I16
ROUTINE	EntityPhysicsWithCollisionsNoGravity

	STZ	entityTouchTileFunctionPtr

	; Check Map Collisions
	; ====================

	LDA	z:EntityStruct::yVecl
	IFL_PLUS
		; Entity is falling/Standing
		; --------------------------
		; Check tiles underneath to see if still standing.

		LDA	z:EntityStruct::yVecl + 1
		AND	#$00FF
		ADD	z:EntityStruct::yPos + 1
		ADD	#ENTITY_HEIGHT - ENTITY_YOFFSET
		LSR
		LSR
		LSR
		AND	#$FFFE
		TAX

		LDA	z:EntityStruct::xPos + 1
		SUB	#ENTITY_XOFFSET
		PHA

		AND	#$000F
		ADD	#ENTITY_WIDTH
		DEC
		LSR
		LSR
		LSR
		LSR
		INC
		STA	a:counter

		PLA
		LSR
		LSR
		LSR
		AND	#$FFFE
		ADD	MetaTiles1x16__mapRowAddressTable, X
		TAY

		LDX	a:MetaTiles1x16__map, Y
		LDA	a:metaTilePropertyTable, X
		STA	z:EntityStruct::currentTileProperty
		BRA	_SkipReleadTableYPlus		; speedup, saves 7 cycles

		REPEAT
			LDX	a:MetaTiles1x16__map, Y
			LDA	a:metaTilePropertyTable, X
_SkipReleadTableYPlus:
			TAX

			LDA	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::functionsTable, X
			IF_NOT_ZERO
				STA	entityTouchTileFunctionPtr
			ENDIF

			LDA	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::type, X
			IF_NOT_ZERO
				IF_N_SET
					; If the tile is a platform, test that the entity
					; was fully above it before standing on it.

					; Removed the INC, so it tests the current tile,
					; not the one below the entity
					LDA	z:EntityStruct::yVecl + 1
					AND	#$00FF
					ADD	z:EntityStruct::yPos + 1
					ADD	#ENTITY_HEIGHT - ENTITY_YOFFSET
					AND	#$FFF0
					SUB	#ENTITY_HEIGHT - ENTITY_YOFFSET

					CMP	z:EntityStruct::yPos + 1
					BLT	FallingThroughPlatform
				ENDIF

				STY	z:EntityStruct::standingTile
				STX	z:EntityStruct::currentTileProperty

				; Move entity to above solid tile.

				LDA	z:EntityStruct::yVecl + 1
				AND	#$00FF
				ADD	z:EntityStruct::yPos + 1
				ADD	#ENTITY_HEIGHT - ENTITY_YOFFSET
				INC
				AND	#$FFF0
				SUB	#ENTITY_HEIGHT - ENTITY_YOFFSET

				STA	z:EntityStruct::yPos + 1
				STZ	z:EntityStruct::yVecl

				JMP	End_Y_CollisionTest
			ENDIF

FallingThroughPlatform:
			INY
			INY
			DEC	a:counter
		UNTIL_ZERO

		; not standing on anything, now falling
		STZ	z:EntityStruct::standingTile

		; ::HACK system may think currentTileProperty is a platform, but its not, reflect this::
		; ::MAYDO improve this (extra field for patforms maybe?)::
		LDX	z:EntityStruct::currentTileProperty
		LDA	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::type, X
		IF_N_SET
			LDX	#.loword(TileProperties__EmptyTile)
			STX	z:EntityStruct::currentTileProperty
		ENDIF

	ELSE

		; Entity is moving upwards
		; ------------------------
		STZ	z:EntityStruct::standingTile

		LDA	z:EntityStruct::yVecl + 1
		ORA	#$FF00
		ADD	z:EntityStruct::yPos + 1
		SUB	#ENTITY_YOFFSET
		LSR
		LSR
		LSR
		AND	#$FFFE
		TAX

		LDA	z:EntityStruct::xPos + 1
		SUB	#ENTITY_XOFFSET
		PHA

		AND	#$000F
		ADD	#ENTITY_WIDTH
		DEC
		LSR
		LSR
		LSR
		LSR
		INC
		STA	a:counter

		PLA
		LSR
		LSR
		LSR
		AND	#$FFFE
		ADD	MetaTiles1x16__mapRowAddressTable, X
		TAY

		; Travelling upwards, current tile = start of head
		LDX	a:MetaTiles1x16__map, Y
		LDA	a:metaTilePropertyTable, X
		STA	z:EntityStruct::currentTileProperty
		BRA	_SkipReleadTableYMinus		; speedup, saves 7 cycles

		REPEAT
			LDX	a:MetaTiles1x16__map, Y
			LDA	a:metaTilePropertyTable, X
_SkipReleadTableYMinus:
			TAX

			LDA	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::functionsTable, X
			IF_NOT_ZERO
				STA	entityTouchTileFunctionPtr
			ENDIF

			LDA	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::type, X

			IF_NOT_ZERO
				; Ignore collision if a platform
				IF_N_CLEAR
					; ::TODO head collide::

					LDA	z:EntityStruct::yVecl + 1
					ORA	#$FF00
					ADD	z:EntityStruct::yPos + 1
					SUB	#ENTITY_YOFFSET
					ADD	#METATILES_SIZE
					AND	#$FFF0
					ADD	#ENTITY_YOFFSET
					STA	z:EntityStruct::yPos + 1
				ENDIF
			ENDIF
			INY
			INY

			DEC	a:counter
		UNTIL_ZERO
End_Y_CollisionTest:
	ENDIF


	LDA	z:EntityStruct::xVecl
	IFL_NOT_ZERO
		IFL_PLUS
			; Entity is moving Right
			; ----------------------

			; handle friction
			LDX	z:EntityStruct::currentTileProperty
			SUB	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::friction, X
			IF_MINUS
				STZ	z:EntityStruct::xVecl
				JMP	End_X_CollisionTest
			ENDIF
			STA	z:EntityStruct::xVecl

			; check collisions
			LDA	z:EntityStruct::yPos + 1
			SUB	#ENTITY_YOFFSET
			PHA

			AND	#$000F
			ADD	#ENTITY_HEIGHT
			DEC
			LSR
			LSR
			LSR
			LSR
			INC
			STA	a:counter

			PLA
			LSR
			LSR
			LSR
			AND	#$FFFE
			TAX

			LDA	z:EntityStruct::xVecl + 1
			AND	#$00FF
			ADD	z:EntityStruct::xPos + 1
			ADD	#ENTITY_WIDTH - ENTITY_XOFFSET
			LSR
			LSR
			LSR
			AND	#$FFFE
			ADD	MetaTiles1x16__mapRowAddressTable, X

			REPEAT
				TAY
				LDX	a:MetaTiles1x16__map, Y
				LDA	a:metaTilePropertyTable, X
				TAX

				LDA	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::functionsTable, X
				IF_NOT_ZERO
					STA	entityTouchTileFunctionPtr
				ENDIF

				LDA	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::type, X
				IF_NOT_ZERO
					; Ignore collision if a platform
					IF_N_CLEAR
						LDA	z:EntityStruct::xVecl + 1
						AND	#$00FF
						ADD	z:EntityStruct::xPos + 1
						ADD	#ENTITY_WIDTH - ENTITY_XOFFSET
						INC
						AND	#$FFF0
						SUB	#ENTITY_WIDTH - ENTITY_XOFFSET
						STA	z:EntityStruct::xPos + 1

						STZ	z:EntityStruct::xVecl

						BRL	End_X_CollisionTest
					ENDIF
				ENDIF
				TYA
				ADD	MetaTiles1x16__sizeOfMapRow

				DEC	a:counter
			UNTIL_ZERO
		ELSEL
			; Entity is moving Left
			; ---------------------

			; handle friction
			LDX	z:EntityStruct::currentTileProperty
			ADD	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::friction, X
			IF_PLUS
				STZ	z:EntityStruct::xVecl
				BRA	End_X_CollisionTest
			ENDIF
			STA	z:EntityStruct::xVecl

			; check collisions
			LDA	z:EntityStruct::yPos + 1
			SUB	#ENTITY_YOFFSET
			PHA

			AND	#$000F
			ADD	#ENTITY_HEIGHT
			DEC
			LSR
			LSR
			LSR
			LSR
			INC
			STA	a:counter

			PLA
			LSR
			LSR
			LSR
			AND	#$FFFE
			TAX

			LDA	z:EntityStruct::xVecl + 1
			ORA	#$FF00
			ADD	z:EntityStruct::xPos + 1
			SUB	#ENTITY_XOFFSET
			LSR
			LSR
			LSR
			AND	#$FFFE
			ADD	MetaTiles1x16__mapRowAddressTable, X

			REPEAT
				TAY
				LDX	a:MetaTiles1x16__map, Y
				LDA	a:metaTilePropertyTable, X
				TAX

				LDA	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::functionsTable, X
				IF_NOT_ZERO
					STA	entityTouchTileFunctionPtr
				ENDIF

				LDA	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::type, X
				IF_NOT_ZERO
					; Ignore collision if a platform
					IF_N_CLEAR
						LDA	z:EntityStruct::xVecl + 1
						ORA	#$FF00
						ADD	z:EntityStruct::xPos + 1
						SUB	#ENTITY_XOFFSET
						ADD	#METATILES_SIZE
						AND	#$FFF0
						ADD	#ENTITY_XOFFSET
						STA	z:EntityStruct::xPos + 1

						STZ	z:EntityStruct::xVecl

						BRA	End_X_CollisionTest
					ENDIF
				ENDIF
				TYA
				ADD	MetaTiles1x16__sizeOfMapRow

				DEC	a:counter
			UNTIL_ZERO
		ENDIF
End_X_CollisionTest:
	ENDIF


	.assert * = EntitySimplePhysics, lderror, "Bad Flow"



; ZP = Entity
.A16
.I16
ROUTINE EntitySimplePhysics

	; Add xVecl, yVecl to xPos/yPos
	; =============================

	; ::KUDOS Khaz::
	; ::: http://forums.nesdev.com/viewtopic.php?f=12&t=12459&p=142645#p142674 ::
	CLC
	LDA	z:EntityStruct::xVecl
	IF_MINUS
		; xVecl is negative
		; Fastest case by 1 cycle if no underflow, otherwise slowest by 2 cycles

		ADC	z:EntityStruct::xPos
		STA	z:EntityStruct::xPos
		BCS	Process_End_XPos
			; 16 bit underflow - subtract by one
			SEP	#$20        ; 8 bit A
				DEC	z:EntityStruct::xPos + 2
			REP     #$20        ; 16 bit A again
	ELSE
		; else - sint16 is positive
		ADC	z:EntityStruct::xPos
		STA	z:EntityStruct::xPos
		BCC	Process_End_XPos
			; 16 bit overflow - add carry
			SEP	#$20        ; 8 bit A
				INC	z:EntityStruct::xPos + 2
			REP	#$20        ; 16 bit A again
Process_End_XPos:
	ENDIF

	CLC
	LDA	z:EntityStruct::yVecl
	IF_MINUS
		; yVecl is negative
		; Fastest case by 1 cycle if no underflow, otherwise slowest by 2 cycles

		ADC	z:EntityStruct::yPos
		STA	z:EntityStruct::yPos
		BCS	Process_End_YPos
			; 16 bit underflow - subtract by one
			SEP	#$20        ; 8 bit A
			DEC	z:EntityStruct::yPos + 2
			REP     #$20        ; 16 bit A again
	ELSE
		; else - sint16 is positive
		ADC	z:EntityStruct::yPos
		STA	z:EntityStruct::yPos
		BCC	Process_End_YPos
			; 16 bit overflow - add carry
			SEP	#$20        ; 8 bit A
			INC	z:EntityStruct::yPos + 2
			REP	#$20        ; 16 bit A again
Process_End_YPos:
	ENDIF

	RTS


ENDMODULE

