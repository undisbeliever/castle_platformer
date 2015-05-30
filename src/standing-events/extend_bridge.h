.ifndef ::_STANDINGEVENTS_EXTEND_BRIDGE_H_
::_STANDINGEVENTS_EXTEND_BRIDGE_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"


IMPORT_MODULE StandingEvents_ExtendBridge
	;; Extends a bridge until it reaches a non-zero tile.
	;; INPUT: A - tile of bridge location on Map
	;; 	 DP - Entity.
	ROUTINE ExtendBridge
ENDMODULE

.endif ; ::_STANDINGEVENTS_EXTEND_BRIDGE_H_

; vim: set ft=asm:

