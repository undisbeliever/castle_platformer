.ifndef ::_STANDINGEVENTS_LOAD_MAP_H_
::_STANDINGEVENTS_LOAD_MAP_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"


IMPORT_MODULE StandingEvents_LoadMap
	;; Stops the current gameloop and loads a different map.
	;; INPUT: A - the new map to load
	;; 	 DP - Entity.
	ROUTINE LoadMap
ENDMODULE

.endif ; ::_STANDINGEVENTS_LOAD_MAP_H_

; vim: set ft=asm:

