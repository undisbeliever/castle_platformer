; Initialisation code

.define VERSION 2
.define REGION NTSC
.define ROM_NAME "CASTLE PLATFORMER"

.include "includes/sfc_header.inc"
.include "includes/import_export.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"
.include "routines/screen.h"
.include "routines/block.h"

.include "credits.h"
.include "gameloop.h"

.export StartingMapCheatAddress := _MapLDA + 1

;; Initialisation Routine
ROUTINE Main
	REP	#$10
	SEP	#$20
.A8
.I16
	; start on map 0
_MapLDA:
	LDA	#0
	STA	GameLoop__map

	JSR	GameLoop__Init
	JSR	GameLoop__PlayGame

	JMP	Credits__ShowCredits
	

.segment "COPYRIGHT"
		;1234567890123456789012345678901
	.byte	"Castle Platformer              ", 10
	.byte	"(c) 2015, The Undisbeliever    ", 10
	.byte	"MIT Licensed, CC0 licensed Art ", 10
	.byte	"One Game Per Month Challange   ", 10

