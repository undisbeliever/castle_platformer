.ifndef ::_CREDITS_H_
::_CREDITS_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"


IMPORT_MODULE Credits
	;; Fades out the screen and displays the credits.
	;;
	;; REQUIRES: 8 bit A, 16 bit Index, DB access registers
	ROUTINE ShowCredits
ENDMODULE

.endif ; ::_CREDITS_H_

; vim: set ft=asm:

