; Initialisation code

.include "gameloop.h"
.include "includes/import_export.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"
.include "routines/screen.h"

.include "maploader.h"
.include "controller.h"
.include "player.h"
.include "physics.h"

.include "routines/block.h"
.include "routines/background-events.h"
.include "routines/metatiles/metatiles-1x16.h"
.include "routines/metasprite.h"

MODULE GameLoop

.segment "SHADOW"
	BYTE	level
	BYTE	state

	WORD	tmp
.code

.rodata

;; A Table of functions to execute for each game state.
;; Must match `GameState` enum.
LABEL	GameStateTable
	.addr	PlayGame
	.addr	NotPlaying
	.addr	Dead
	.addr	GameOver


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

	JSR	BackgroundEvents__Init

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

			JSR	BackgroundEvents__Process

			; reset DP
			LDA	#0
			TCD

			SEP	#$20
.A8
		PLB

		JSR	MetaTiles1x16__Update

		JSR	Entities__Render

		LDA	state
	UNTIL_NOT_ZERO

	LDA	#0
	XBA
	LDA	state
	ASL
	TAX

	JMP	(.loword(GameStateTable), X)


.A8
.I16
ROUTINE NotPlaying
	RTS


DEATH_GRAVITY = 40
DEATH_JUMP = 1024


;; Player is dead
;; Do the 'death' animation, wait for buttonpress, restart map.
.A8
.I16
ROUTINE Dead
	PHB
	LDA	#$7E
	PHA
	PLB

	; ::SHOULDDO set player animation to death::

	; Player 'jumps to bottom of screen'

	REP	#$30
.A16
	LDA	#Player__entity
	TCD

	STZ	z:EntityStruct::xVecl
	LDA	#.loword(-DEATH_JUMP)
	STA	z:EntityStruct::yVecl

	LDA	MetaTiles1x16__yPos
	ADD	#224 + 1
	ADD	z:EntityStruct::size_yOffsetTop
	STA	tmp

	SEP	#$20
.A8

	REPEAT
		JSR	Screen__WaitFrame

		REP	#$30
.A16
		LDA	z:EntityStruct::yVecl
		ADD	#DEATH_GRAVITY
		STA	z:EntityStruct::yVecl

		JSR	Physics__EntitySimplePhysics

		SEP	#$20
.A8
		JSR	Entities__Render

		LDY	a:Player__entity + EntityStruct::yPos + 1
		CPY	tmp
	UNTIL_GE

	LDA	#0
	XBA
	LDA	#0
	TCD

	; Wait for buttonpress
	REPEAT
		JSR	Screen__WaitFrame

		LDX	Controller__pressed
	UNTIL_NOT_ZERO

	PLB
	JSR	Init
	JMP	PlayGame



;; Exit the game loop
.A8
.I16
ROUTINE GameOver
	RTS



ENDMODULE

