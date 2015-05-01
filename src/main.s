; Initialisation code

.define VERSION 1
.define REGION NTSC
.define ROM_NAME "CASTLE PLATFORM DEMO"

.include "includes/sfc_header.inc"
.include "includes/import_export.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"
.include "routines/screen.h"
.include "routines/block.h"

.include "gameloop.h"


;; Initialisation Routine
ROUTINE Main
	REP	#$10
	SEP	#$20
.A8
.I16
	JSR	GameLoop__Init
	JSR	GameLoop__PlayGame

	JMP	ShowToBeContinued


.A8
.I16
ROUTINE ShowToBeContinued
	; ::TODO create a generic show image routines::
	; Show To be Continued Message
	JSR	Screen__FadeOut

	LDA	#INIDISP_FORCE
	STA	INIDISP

	LDA	#TM_BG1
	STA	TM

	STZ	BG1HOFS
	STZ	BG1HOFS
	STZ	BG1VOFS
	STZ	BG1VOFS

	TransferToVramLocation	ToBeContinuedMap, GAMELOOP_BG1_MAP
	TransferToVramLocation	ToBeContinuedTiles, GAMELOOP_BG1_TILES
	TransferToCgramLocation	ToBeContinuedPalette, 0

	JSR	Screen__FadeIn

	REPEAT
	FOREVER


.segment "BANK1"
	INCLUDE_BINARY ToBeContinuedMap,	"resources/to_be_continued.map"
	INCLUDE_BINARY ToBeContinuedTiles,	"resources/to_be_continued.4bpp"
	INCLUDE_BINARY ToBeContinuedPalette,	"resources/to_be_continued.clr"
	

.segment "COPYRIGHT"
		;1234567890123456789012345678901
	.byte	"Castle Platformer Demo         ", 10
	.byte	"(c) 2015, The Undisbeliever    ", 10
	.byte	"MIT Licensed, CC0 licensed Art ", 10
	.byte	"One Game Per Month Challange   ", 10

