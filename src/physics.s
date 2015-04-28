
.include "physics.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "maploader.h"

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


	WORD	counter
.code


; ZP = Entity
.A16
.I16
ROUTINE ProcessEntity

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


	; Check Map Collisions
	; ====================

	LDA	z:EntityStruct::yVecl
	IF_PLUS
		; falling/standing. Check tiles underneath to see if still standing.

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
		STA	z:EntityStruct::currentTile
		BRA	_SkipReleadTableYPlus		; speedup, saves 7 cycles

		REPEAT
			LDX	a:MetaTiles1x16__map, Y
			LDA	a:metaTilePropertyTable, X
_SkipReleadTableYPlus:
			TAX
			LDA	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::solid, X
			IF_NOT_ZERO
				STX	z:EntityStruct::standingTile
				STX	z:EntityStruct::currentTile

				LDA	z:EntityStruct::yVecl + 1
				AND	#$00FF
				ADD	z:EntityStruct::yPos + 1
				ADD	#ENTITY_HEIGHT - ENTITY_YOFFSET
				INC
				AND	#$FFF0
				SUB	#ENTITY_HEIGHT - ENTITY_YOFFSET
				STA	z:EntityStruct::yPos + 1

				STZ	z:EntityStruct::yVecl

				BRA	End_Y_CollisionTest
			ENDIF
			INY
			INY

			DEC	a:counter
		UNTIL_ZERO

		; not standing on anything, now falling
		STZ	z:EntityStruct::standingTile
	ELSE
		; raising through the tiles.
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
		STA	z:EntityStruct::currentTile
		BRA	_SkipReleadTableYMinus		; speedup, saves 7 cycles

		REPEAT
			LDX	a:MetaTiles1x16__map, Y
			LDA	a:metaTilePropertyTable, X
_SkipReleadTableYMinus:
			TAX
			LDA	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::solid, X

			IF_NOT_ZERO
				; ::TODO head collide::
				; ::TODO platform test::

				LDA	z:EntityStruct::yVecl + 1
				ORA	#$FF00
				ADD	z:EntityStruct::yPos + 1
				SUB	#ENTITY_YOFFSET
				ADD	#METATILES_SIZE
				AND	#$FFF0
				ADD	#ENTITY_YOFFSET
				STA	z:EntityStruct::yPos + 1

				STZ	z:EntityStruct::yVecl

				BRA	End_Y_CollisionTest
			ENDIF
			INY
			INY

			DEC	a:counter
		UNTIL_ZERO
	ENDIF

End_Y_CollisionTest:



	LDA	z:EntityStruct::xVecl
	IFL_NOT_ZERO
		IF_PLUS
			; moving Right
			; handle friction
			LDX	z:EntityStruct::currentTile
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
				LDA	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::solid, X
				IF_NOT_ZERO
					LDA	z:EntityStruct::xVecl + 1
					AND	#$00FF
					ADD	z:EntityStruct::xPos + 1
					ADD	#ENTITY_WIDTH - ENTITY_XOFFSET
					INC
					AND	#$FFF0
					SUB	#ENTITY_WIDTH - ENTITY_XOFFSET
					STA	z:EntityStruct::xPos + 1

					STZ	z:EntityStruct::xVecl

					JMP	End_X_CollisionTest
				ENDIF
				TYA
				ADD	MetaTiles1x16__sizeOfMapRow

				DEC	a:counter
			UNTIL_ZERO
		ELSE
			; moving Left
			; handle friction
			LDX	z:EntityStruct::currentTile
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
				LDA	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::solid, X
				IF_NOT_ZERO
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
				TYA
				ADD	MetaTiles1x16__sizeOfMapRow

				DEC	a:counter
			UNTIL_ZERO
		ENDIF
	ENDIF

End_X_CollisionTest:

	; Add xVecl, yVecl to xPos/yPos
	; -----------------------------

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

