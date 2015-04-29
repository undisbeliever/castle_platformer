; Initialisation code

.include "gameloop.h"
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

MODULE GameLoop

.segment "SHADOW"
	BYTE	level
	BYTE	state

.code

.A8
.I16
ROUTINE Init
	STZ	NMITIMEN

	LDA	#INIDISP_FORCE
	STA	INIDISP

	LDA	#GAMELOOP_SCREEN_MODE
	STA	BGMODE

	MetaSprite_Init
	Screen_SetVramBaseAndSize GAMELOOP

	LDA	level
	JSR	MapLoader__LoadMap

	; ::TODO dynamicaly load player::
	JSR	Player__Init

	LDA	#TM_BG1 | TM_OBJ
	STA	TM

	LDA	#NMITIMEN_VBLANK_FLAG | NMITIMEN_AUTOJOY_FLAG
	STA	NMITIMEN

	LDA	#$0F
	STA	INIDISP

	RTS



.A8
.I16
ROUTINE PlayGame
	STZ	state

	REPEAT
		JSR	Screen__WaitFrame

		PHD
		PHB
		LDA	#$7E
		PHA
		PLB

			REP	#$30
.A16
			LDA	#Player__entity
			TCD

			JSR	Player__Update
			JSR	Player__SetScreenPosition

			SEP	#$20
.A8
		PLB

		JSR	MetaTiles1x16__Update

		JSR	Entities__Render

		PLD

		LDA	state
	UNTIL_NOT_ZERO

	RTS
