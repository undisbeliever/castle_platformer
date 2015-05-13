.ifndef ::_ENTITIES_NPC_UNMOVING_H_
::_ENTITIES_NPC_UNMOVING_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

.include "../entities.h"

IMPORT_MODULE Npc_Unmoving
	;; ENTITY PARAMETER: if non-zero then the entity cannot kill the player.
	LABEL	InitState
ENDMODULE

.endif ; ::_ENTITIES_NPC_UNMOVING_H_

; vim: set ft=asm:

