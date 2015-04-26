.ifndef ::_PLAYER_H_
::_PLAYER_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

IMPORT_MODULE Player
	;; Initialize the player
	;; REQUIRE: 8 bit A, 16 bit Index, DB access registers
	ROUTINE Init

	;; Updates the player state
	;; REQUIRE: 8 bit A, 16 bit Index, DB access registers
	ROUTINE Update

	;; Displays the player's metasprite
	;; REQUIRE: 8 bit A, 16 bit Index, DB access registers
	ROUTINE Render
ENDMODULE

.endif ; ::_PLAYER_H_

; vim: set ft=asm:

