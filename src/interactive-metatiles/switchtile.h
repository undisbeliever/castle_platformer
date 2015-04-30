.ifndef ::_SWITCHTILE_H_
::_SWITCHTILE_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"


IMPORT_MODULE SwitchTile
	LABEL	functionsTable
ENDMODULE

.endif ; ::_SWITCHTILE_H_

; vim: set ft=asm:

