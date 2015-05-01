.ifndef ::_STANDINGEVENTS_REMOVECHAIN_H_
::_STANDINGEVENTS_REMOVECHAIN_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"


IMPORT_MODULE StandingEvents_RemoveChain
	;; Removes a chain upwards.
	;; Chain must be two rows tall, 1 row wide.
	;; INPUT: A - chain location on Map
	;; 	 DP - Entity.
	ROUTINE RemoveChain
ENDMODULE

.endif ; ::_STANDINGEVENTS_REMOVECHAIN_H_

; vim: set ft=asm:

