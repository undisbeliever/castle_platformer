
.ifndef ::_GAMELOOP_H_
::_GAMELOOP_H_ = 1

.setcpu "65816"
.include "includes/import_export.inc"
.include "includes/registers.inc"

.enum	GameState
	PLAYING	= 0
	NOT_PLAYING
	DEAD
	GAME_OVER
	LOAD_NEW_MAP
.endenum


GAMELOOP_SCREEN_MODE	= BGMODE_MODE1
GAMELOOP_BG1_MAP 	= $0000
GAMELOOP_BG1_TILES	= $3000
GAMELOOP_BG1_SIZE	= BGXSC_SIZE_64X32
GAMELOOP_OAM_TILES	= $6000

GAMELOOP_OAM_SIZE	= OBSEL_SIZE_8_16
GAMELOOP_OAM_NAME	= 0


IMPORT_MODULE GameLoop
	;; The current map being played.
	BYTE	map

	;; The curret game state. Possible values are of `GameState`
	;; Can be set by any of the process functions, checked at the start of
	;; every frame.
	BYTE	state


	;; Initializes the game loop.
	;;	* Loads the map
	;;	* Loads the player
	;;
	;; REQUIRES: 8 bit A, 16 bit Index, DP = 0, Force Blank
	;; INPUT: A - the map number to load. 
	ROUTINE	Init

	;; Processes the gameloop until the game mode changes to `GameState::STOPPED`.
	;; REQUIRES: 8 bit A, 16 bit Index
	ROUTINE PlayGame
ENDMODULE

.endif ; ::_GAMELOOP_H_

; vim: ft=asm:

