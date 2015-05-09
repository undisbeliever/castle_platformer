.ifndef ::_SPIKEDTILE_H_
::_SPIKEDTILE_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

IMPORT_MODULE SpikedTile
	LABEL	functionsTable
ENDMODULE

.endif ; ::_SPIKEDTILE_H_

; vim: set ft=asm:

