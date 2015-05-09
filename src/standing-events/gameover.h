.ifndef ::_STANDINGEVENTS_GAMEOVER_H_
::_STANDINGEVENTS_GAMEOVER_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"


IMPORT_MODULE StandingEvents_GameOver
	;; Removes a bridge rightwards
	;; INPUT: A - leftmost tile of bridge location on Map
	;; 	 DP - Entity.
	ROUTINE GameOver
ENDMODULE

.endif ; ::_STANDINGEVENTS_GAMEOVER_H_

; vim: set ft=asm:

