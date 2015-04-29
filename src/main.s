; Initialisation code

.define VERSION 1
.define REGION NTSC
.define ROM_NAME "CASTLE PLATFORM DEMO"

.include "includes/sfc_header.inc"
.include "includes/import_export.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"
.include "routines/screen.h"

.include "gameloop.h"


;; Initialisation Routine
ROUTINE Main
	REP	#$10
	SEP	#$20
.A8
.I16
	REPEAT
		JSR	GameLoop__Init
		JSR	GameLoop__PlayGame
	FOREVER


.segment "COPYRIGHT"
		;1234567890123456789012345678901
	.byte	"Castle Platformer Demo         ", 10
	.byte	"(c) 2015, The Undisbeliever    ", 10
	.byte	"MIT Licensed, CC0 licensed Art ", 10
	.byte	"One Game Per Month Challange   ", 10

