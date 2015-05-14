.ifndef ::_ENTITIES_NPC_WALK_AND_TURN_H_
::_ENTITIES_NPC_WALK_AND_TURN_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

.include "../entities.h"

;; The Walk and Turn NPC will walk in a given direction
;; and turn around when it collides with a wall or detects
;; an edge in front of them.
;;
;; When the player touches the entity, the player will die.
;;
;; The paramter for this entity is the number of pixels
;; from the edge of the AABB to test. This number must
;; be large enough that the entity does not slide off the
;; edge. The default (used if param is NULL) is 8.

IMPORT_MODULE Npc_WalkAndTurn
	;; PARAM: ledgeCheckOffset
	LABEL	WalkLeft

	;; PARAM: ledgeCheckOffset
	LABEL	WalkRight
ENDMODULE

.endif ; ::_ENTITIES_NPC_WALK_AND_TURN_H_

; vim: set ft=asm:

