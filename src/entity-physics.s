
.include "entity-physics.h"
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


MODULE EntityPhysics

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

	LDX	z:EntityPhysicsStruct::currentTileProperty

	IF_BIT	#JOY_LEFT
		LDA	z:EntityPhysicsStruct::xVecl
		SUB	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::walkAcceleration, X
		CMP	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::minimumXVelocity, X
		IF_SLT
			LDA	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::minimumXVelocity, X
		ENDIF
		STA	z:EntityPhysicsStruct::xVecl

	ELSE_BIT #JOY_RIGHT
		LDA	z:EntityPhysicsStruct::xVecl
		ADD	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::walkAcceleration, X
		CMP	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::maximumXVelocity, X
		IF_SGE
			LDA	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::maximumXVelocity, X
		ENDIF
		STA	z:EntityPhysicsStruct::xVecl
	ENDIF

	PLA

	; Jump only if standing.
	LDY	z:EntityPhysicsStruct::standingTile
	IF_NOT_ZERO
		IF_BIT	#JOY_B
			LDX	z:EntityPhysicsStruct::currentTileProperty
			LDA	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::jumpingVelocity, X
			IF_NOT_ZERO
				STA	z:EntityPhysicsStruct::yVecl
			ENDIF
		ENDIF
	ENDIF

	RTS



; ZP = Entity
.A16
.I16
ROUTINE EntityPhysicsWithCollisions

	LDA	z:EntityPhysicsStruct::yVecl
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
	STA	z:EntityPhysicsStruct::yVecl

	.assert * = EntityPhysicsWithCollisionsNoGravity, lderror, "Bad Flow"



; ZP = Entity
.A16
.I16
ROUTINE	EntityPhysicsWithCollisionsNoGravity

	STZ	entityTouchTileFunctionPtr

	; Check Map Collisions
	; ====================

	LDA	z:EntityPhysicsStruct::yVecl
	IFL_PLUS
		; Entity is falling/Standing
		; --------------------------
		; Check tiles underneath to see if still standing.

		; mapYpos = (entity->yVecl.int + entity->yPos.int - entity->size_yOffset + entity->size_height) / 16 * 2
		; tmp = entity->xPos.int - entity->size_xOffset
		; counter = (tmp & 0x000F + entity->size_width - 1) / 16 + 1	// number of tiles to test
		; mapXpos = tmp / 16 * 2
		; mapPos = mapXpos + MetaTiles1x16__mapRowAddressTable[mapYpos]

		; A = entity->yVecl
		XBA
		AND	#$00FF
		ADD	z:EntityPhysicsStruct::yPos + 1
		SUB	z:EntityPhysicsStruct::size_yOffset
		ADD	z:EntityPhysicsStruct::size_height
		LSR
		LSR
		LSR
		AND	#$FFFE
		TAX

		LDA	z:EntityPhysicsStruct::xPos + 1
		SUB	z:EntityPhysicsStruct::size_xOffset
		PHA

		AND	#$000F
		ADD	z:EntityPhysicsStruct::size_width
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
		STA	z:EntityPhysicsStruct::currentTileProperty
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
					LDA	z:EntityPhysicsStruct::yVecl + 1
					AND	#$00FF
					ADD	z:EntityPhysicsStruct::yPos + 1
					SUB	z:EntityPhysicsStruct::size_yOffset
					ADD	z:EntityPhysicsStruct::size_height
					AND	#$FFF0
					ADD	z:EntityPhysicsStruct::size_yOffset
					SUB	z:EntityPhysicsStruct::size_height

					CMP	z:EntityPhysicsStruct::yPos + 1
					BLT	FallingThroughPlatform
				ENDIF

				STY	z:EntityPhysicsStruct::standingTile
				STX	z:EntityPhysicsStruct::currentTileProperty

				; Move entity to above solid tile.
				LDA	z:EntityPhysicsStruct::yVecl + 1
				AND	#$00FF
				ADD	z:EntityPhysicsStruct::yPos + 1
				SUB	z:EntityPhysicsStruct::size_yOffset
				ADD	z:EntityPhysicsStruct::size_height
				INC
				AND	#$FFF0
				ADD	z:EntityPhysicsStruct::size_yOffset
				SUB	z:EntityPhysicsStruct::size_height

				STA	z:EntityPhysicsStruct::yPos + 1
				STZ	z:EntityPhysicsStruct::yVecl

				JMP	End_Y_CollisionTest
			ENDIF

FallingThroughPlatform:
			INY
			INY
			DEC	a:counter
		UNTIL_ZERO

		; not standing on anything, now falling
		STZ	z:EntityPhysicsStruct::standingTile

		; ::HACK system may think currentTileProperty is a platform, but its not, reflect this::
		; ::MAYDO improve this (extra field for patforms maybe?)::
		LDX	z:EntityPhysicsStruct::currentTileProperty
		LDA	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::type, X
		IF_N_SET
			LDX	#.loword(TileProperties__EmptyTile)
			STX	z:EntityPhysicsStruct::currentTileProperty
		ENDIF

	ELSE

		; Entity is moving upwards
		; ------------------------

		; mapYpos = (entity->yVecl.int + entity->yPos.int - entity->size_yOffset) / 16 * 2
		; tmp = entity->xPos.int - entity->size_xOffset
		; counter = (tmp & 0x000F + entity->size_width - 1) / 16 + 1	// number of tiles to test
		; mapXpos = tmp / 16 * 2
		; mapPos = mapXpos + MetaTiles1x16__mapRowAddressTable[mapYpos]

		STZ	z:EntityPhysicsStruct::standingTile

		; A = entity->yVecl and negative.
		XBA
		ORA	#$FF00
		ADD	z:EntityPhysicsStruct::yPos + 1
		SUB	z:EntityPhysicsStruct::size_yOffset
		LSR
		LSR
		LSR
		AND	#$FFFE
		TAX

		LDA	z:EntityPhysicsStruct::xPos + 1
		SUB	z:EntityPhysicsStruct::size_xOffset
		PHA

		AND	#$000F
		ADD	z:EntityPhysicsStruct::size_width
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
		STA	z:EntityPhysicsStruct::currentTileProperty
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

					LDA	z:EntityPhysicsStruct::yVecl + 1
					ORA	#$FF00
					ADD	z:EntityPhysicsStruct::yPos + 1
					SUB	z:EntityPhysicsStruct::size_yOffset
					ADD	#METATILES_SIZE
					AND	#$FFF0
					ADD	z:EntityPhysicsStruct::size_yOffset
					STA	z:EntityPhysicsStruct::yPos + 1

					STZ	z:EntityPhysicsStruct::yVecl

					BRA	End_Y_CollisionTest
				ENDIF
			ENDIF
			INY
			INY

			DEC	a:counter
		UNTIL_ZERO
End_Y_CollisionTest:
	ENDIF


	LDA	z:EntityPhysicsStruct::xVecl
	IFL_NOT_ZERO
		IFL_PLUS
			; Entity is moving Right
			; ----------------------

			; handle friction
			LDX	z:EntityPhysicsStruct::currentTileProperty
			SUB	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::friction, X
			IF_MINUS
				STZ	z:EntityPhysicsStruct::xVecl
				JMP	End_X_CollisionTest
			ENDIF
			STA	z:EntityPhysicsStruct::xVecl

			; check collisions

			; tmp = entity->yPos.int + - entity->size_yOffset
			; counter = (tmp & 0x000F + entity->size_height - 1) / 16 + 1	// number of tiles to test
			; mapYPos = tmp / 16 * 2
			; mapXpos = (entity->xVecl.int + entity->xPos.int - entity->size_xOffset + entity->size_width) / 16 * 2
			; mapPos = mapXpos + MetaTiles1x16__mapRowAddressTable[mapYpos]

			LDA	z:EntityPhysicsStruct::yPos + 1
			SUB	z:EntityPhysicsStruct::size_yOffset
			PHA

			AND	#$000F
			ADD	z:EntityPhysicsStruct::size_height
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

			LDA	z:EntityPhysicsStruct::xVecl + 1
			AND	#$00FF
			ADD	z:EntityPhysicsStruct::xPos + 1
			SUB	z:EntityPhysicsStruct::size_xOffset
			ADD	z:EntityPhysicsStruct::size_width
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
						LDA	z:EntityPhysicsStruct::xVecl + 1
						AND	#$00FF
						ADD	z:EntityPhysicsStruct::xPos + 1
						SUB	z:EntityPhysicsStruct::size_xOffset
						ADD	z:EntityPhysicsStruct::size_width
						INC
						AND	#$FFF0
						ADD	z:EntityPhysicsStruct::size_xOffset
						SUB	z:EntityPhysicsStruct::size_width
						STA	z:EntityPhysicsStruct::xPos + 1

						STZ	z:EntityPhysicsStruct::xVecl

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
			LDX	z:EntityPhysicsStruct::currentTileProperty
			ADD	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::friction, X
			IF_PLUS
				STZ	z:EntityPhysicsStruct::xVecl
				BRA	End_X_CollisionTest
			ENDIF
			STA	z:EntityPhysicsStruct::xVecl

			; check collisions

			; tmp = entity->yPos.int + - entity->size_yOffset
			; counter = (tmp & 0x000F + entity->size_height - 1) / 16 + 1	// number of tiles to test
			; mapYPos = tmp / 16 * 2
			; mapXpos = (entity->xVecl.int + entity->xPos.int - entity->size_xOffset) / 16 * 2
			; mapPos = mapXpos + MetaTiles1x16__mapRowAddressTable[mapYpos]

			LDA	z:EntityPhysicsStruct::yPos + 1
			SUB	z:EntityPhysicsStruct::size_yOffset
			PHA

			AND	#$000F
			ADD	z:EntityPhysicsStruct::size_height
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

			LDA	z:EntityPhysicsStruct::xVecl + 1
			ORA	#$FF00
			ADD	z:EntityPhysicsStruct::xPos + 1
			SUB	z:EntityPhysicsStruct::size_xOffset
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
						LDA	z:EntityPhysicsStruct::xVecl + 1
						ORA	#$FF00
						ADD	z:EntityPhysicsStruct::xPos + 1
						SUB	z:EntityPhysicsStruct::size_xOffset
						ADD	#METATILES_SIZE
						AND	#$FFF0
						ADD	z:EntityPhysicsStruct::size_xOffset
						STA	z:EntityPhysicsStruct::xPos + 1

						STZ	z:EntityPhysicsStruct::xVecl

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
	LDA	z:EntityPhysicsStruct::xVecl
	IF_MINUS
		; xVecl is negative
		; Fastest case by 1 cycle if no underflow, otherwise slowest by 2 cycles

		ADC	z:EntityPhysicsStruct::xPos
		STA	z:EntityPhysicsStruct::xPos
		BCS	Process_End_XPos
			; 16 bit underflow - subtract by one
			SEP	#$20        ; 8 bit A
				DEC	z:EntityPhysicsStruct::xPos + 2
			REP     #$20        ; 16 bit A again
	ELSE
		; else - sint16 is positive
		ADC	z:EntityPhysicsStruct::xPos
		STA	z:EntityPhysicsStruct::xPos
		BCC	Process_End_XPos
			; 16 bit overflow - add carry
			SEP	#$20        ; 8 bit A
				INC	z:EntityPhysicsStruct::xPos + 2
			REP	#$20        ; 16 bit A again
Process_End_XPos:
	ENDIF

	CLC
	LDA	z:EntityPhysicsStruct::yVecl
	IF_MINUS
		; yVecl is negative
		; Fastest case by 1 cycle if no underflow, otherwise slowest by 2 cycles

		ADC	z:EntityPhysicsStruct::yPos
		STA	z:EntityPhysicsStruct::yPos
		BCS	Process_End_YPos
			; 16 bit underflow - subtract by one
			SEP	#$20        ; 8 bit A
			DEC	z:EntityPhysicsStruct::yPos + 2
			REP     #$20        ; 16 bit A again
	ELSE
		; else - sint16 is positive
		ADC	z:EntityPhysicsStruct::yPos
		STA	z:EntityPhysicsStruct::yPos
		BCC	Process_End_YPos
			; 16 bit overflow - add carry
			SEP	#$20        ; 8 bit A
			INC	z:EntityPhysicsStruct::yPos + 2
			REP	#$20        ; 16 bit A again
Process_End_YPos:
	ENDIF

	RTS


ENDMODULE

