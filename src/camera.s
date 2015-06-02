
.include "camera.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "entities.h"
.include "entities/player.h"

.include "routines/screen.h"
.include "routines/metatiles/metatiles-1x16.h"

MODULE Camera

; ::TODO move somewhere else
SCREEN_LEFT_RIGHT_SPACING = 110
SCREEN_UP_DOWN_SPACING = 75

SHAKE_SCREEN_FRAME_DELAY = 2
SHAKE_SCREEN_AMOUNT = 3

.segment "WRAM7E"
	BYTE	shaking
	BYTE	shakingCounter

	ADDR	focusedEntity
.code

; DB = unknown
.A8
.I16
ROUTINE Init
	REP	#$30
.A16
	LDA	#Entities__player
	STA	f:focusedEntity

	SEP	#$20
.A8

	RTS


.A16
.I16
ROUTINE	Update
	LDA	focusedEntity
	TCD

	LDA	z:EntityStruct::xPos + 1
	SUB	MetaTiles1x16__xPos
	CMP	#256 - SCREEN_LEFT_RIGHT_SPACING
	IF_SGE
		LDA	z:EntityStruct::xPos + 1
		SUB	#256 - SCREEN_LEFT_RIGHT_SPACING
		CMP	MetaTiles1x16__maxXPos
		IF_GE
			LDA	MetaTiles1x16__maxXPos
		ENDIF
		STA	MetaTiles1x16__xPos
	ELSE
		CMP	#SCREEN_LEFT_RIGHT_SPACING
		IF_SLT
			LDA	z:EntityStruct::xPos + 1
			SUB	#SCREEN_LEFT_RIGHT_SPACING
			IF_MINUS
				LDA	#0
			ENDIF
			STA	MetaTiles1x16__xPos
		ENDIF
	ENDIF

	LDA	z:EntityStruct::yPos + 1
	SUB	MetaTiles1x16__yPos
	CMP	#224 - SCREEN_UP_DOWN_SPACING
	IF_SGE
		LDA	z:EntityStruct::yPos + 1
		SUB	#224 - SCREEN_UP_DOWN_SPACING
		CMP	MetaTiles1x16__maxYPos
		IF_GE
			LDA	MetaTiles1x16__maxYPos
		ENDIF
		STA	MetaTiles1x16__yPos
	ELSE
		CMP	#SCREEN_UP_DOWN_SPACING
		IF_SLT
			LDA	z:EntityStruct::yPos + 1
			SUB	#SCREEN_UP_DOWN_SPACING
			IF_MINUS
				LDA	#0
			ENDIF
			STA	MetaTiles1x16__yPos
		ENDIF
	ENDIF

	SEP	#$20
.A8
	LDA	shaking
	IF_NOT_ZERO
		STZ	shaking

		LDA	shakingCounter
		INC	shakingCounter

		.assert (SHAKE_SCREEN_FRAME_DELAY & (SHAKE_SCREEN_FRAME_DELAY - 1)) = 0, error, "SHAKE_SCREEN_FRAME_DELAY must be a power of 2"

		IF_NOT_BIT #SHAKE_SCREEN_FRAME_DELAY - 1
			REP	#$30
.A16
			IF_BIT	#SHAKE_SCREEN_FRAME_DELAY
				LDA	MetaTiles1x16__yPos
				ADD	#SHAKE_SCREEN_AMOUNT
			ELSE
				LDA	MetaTiles1x16__yPos
				SUB	#SHAKE_SCREEN_AMOUNT
			ENDIF

			STA	MetaTiles1x16__yPos
		ENDIF
	ENDIF

	REP	#$30
.A16

	RTS



ENDMODULE

