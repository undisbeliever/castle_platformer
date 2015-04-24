; Initialisation code

.define VERSION 1
.define REGION NTSC
.define ROM_NAME "CASTLE PLATFORM DEMO"

.include "includes/sfc_header.inc"
.include "includes/import_export.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"
.include "routines/screen.h"

.include "maploader.h"
.include "controller.h"

.include "routines/block.h"
.include "routines/metatiles/metatiles-1x16.h"


;; Initialisation Routine
ROUTINE Main
	REP	#$10
	SEP	#$20
.A8
.I16
	LDA	#INIDISP_FORCE
	STA	INIDISP

	LDA	#METATILES_SCREEN_MODE
	STA	BGMODE

	Screen_SetVramBaseAndSize METATILES

	LDA	#0
	JSR	MapLoader__LoadMap

	LDA	#TM_BG1
	STA	TM

	LDA	#NMITIMEN_VBLANK_FLAG | NMITIMEN_AUTOJOY_FLAG
	STA	NMITIMEN

	LDA	#$0F
	STA	INIDISP

	REPEAT
		JSR	Screen__WaitFrame

		LDA	Controller__current + 1
		IF_NOT_ZERO
			IF_BIT	#JOYH_UP
				LDY	MetaTiles1x16__yPos
				DEY
				STY	MetaTiles1x16__yPos
			ENDIF
			IF_BIT	#JOYH_DOWN
				LDY	MetaTiles1x16__yPos
				INY
				STY	MetaTiles1x16__yPos
			ENDIF
			IF_BIT	#JOYH_LEFT
				LDX	MetaTiles1x16__xPos
				DEX
				STX	MetaTiles1x16__xPos
			ENDIF
			IF_BIT	#JOYH_RIGHT
				LDX	MetaTiles1x16__xPos
				INX
				STX	MetaTiles1x16__xPos
			ENDIF

			JSR	MetaTiles1x16__Update
		ENDIF
	FOREVER


.segment "COPYRIGHT"
		;1234567890123456789012345678901
	.byte	"Castle Platformer Demo         ", 10
	.byte	"(c) 2015, The Undisbeliever    ", 10
	.byte	"MIT Licensed, CC0 licensed Art ", 10
	.byte	"One Game Per Month Challange   ", 10

