.ifndef ::_CONTROLLER_H_
::_CONTROLLER_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"


IMPORT_MODULE Controller
	;; New buttons pressed on current frame.
	WORD	pressed

	;; The state of the current frame
	WORD	current

	;; Updates the controller variables
	;; REQUIRE: 8 bit A, 16 bit Index, DB access registers, AUTOJOY enabled
	ROUTINE Update

ENDMODULE

.endif ; ::_CONTROLLER_H_

; vim: set ft=asm:

