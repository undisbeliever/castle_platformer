.ifndef ::_ENTITIES_NPC_STOMPER_H_
::_ENTITIES_NPC_STOMPER_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

.include "../entities.h"

;; The Npc_Stomper emulates the Thwomps from Super Mario World.
IMPORT_MODULE Npc_Stomper
	LABEL	InitState
ENDMODULE

.endif ; ::_ENTITIES_NPC_STOMPER_H_

; vim: set ft=asm:

