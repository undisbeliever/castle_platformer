.ifndef ::_CAMERA_H_
::_CAMERA_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"


IMPORT_MODULE Camera
	;; If set non-zero the camera will be shaking up and down.
	;; Reset to zero every frame.
	;; ACCESS: WRAM7E
	BYTE	shaking

	;; The entity to focus the map on
	;; ACCESS: WRAM7E
	WORD	focusedEntity

	;; Initializes the camera module.
	;; Sets the focused entity to the player.
	;; REQUIRES: 8 bit A, 16 bit Index
	ROUTINE	Init

	;; Updates the map's position, depending on the entity position.
	;; Should be updated once per frame before render.
	;;
	;; REQUIRES: 16 bit A, 16 bit Index, DB=$7E
	;; OUT: DP - the entity to focus on
	ROUTINE Update
ENDMODULE

.endif ; ::_CAMERA_H_

; vim: set ft=asm:

