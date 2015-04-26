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
.include "player.h"

.include "routines/block.h"
.include "routines/metatiles/metatiles-1x16.h"
.include "routines/metasprite.h"


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

	MetaSprite_Init
	Screen_SetVramBaseAndSize METATILES

	LDA	#0
	JSR	MapLoader__LoadMap

	; ::TODO dynamicaly load player::
	JSR	Player__Init

	LDA	#TM_BG1 | TM_OBJ
	STA	TM

	LDA	#NMITIMEN_VBLANK_FLAG | NMITIMEN_AUTOJOY_FLAG
	STA	NMITIMEN

	LDA	#$0F
	STA	INIDISP

	REPEAT
		JSR	Screen__WaitFrame

		JSR	Player__Update
		JSR	MetaTiles1x16__Update

		JSR	MetaSprite__InitLoop
		JSR	Player__Render
		JSR	MetaSprite__FinalizeLoop
	FOREVER


.segment "COPYRIGHT"
		;1234567890123456789012345678901
	.byte	"Castle Platformer Demo         ", 10
	.byte	"(c) 2015, The Undisbeliever    ", 10
	.byte	"MIT Licensed, CC0 licensed Art ", 10
	.byte	"One Game Per Month Challange   ", 10

