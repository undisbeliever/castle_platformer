.ifndef ::_PLAYER_H_
::_PLAYER_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

.include "entities.h"


IMPORT_MODULE Player
	;; The player's EntityStruct.
	STRUCT	entity, EntityStruct

	;; Initialize the player
	;; REQUIRE: 8 bit A, 16 bit Index
	ROUTINE Init

	;; Updates the player state
	;; REQUIRE: 16 bit A, 16 bit Index, DB = $7E
	ROUTINE Update

	;; Updates the map's position, depending on the players position
	;; REQUIRE: 16 bit A, 16 bit Index, DB = $7E or access shadow
	ROUTINE	SetScreenPosition
ENDMODULE

.endif ; ::_PLAYER_H_

; vim: set ft=asm:

