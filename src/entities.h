.ifndef ::_ENTITIES_H_
::_ENTITIES_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

IMPORT_MODULE Entities

	;; Render all of the entities with metatiles.
	;; REQUIRE: 8 bit A, 16 bit Index, DB access registers
	ROUTINE	Render

ENDMODULE

.endif ; ::_ENTITIES_H_

; vim: set ft=asm:

