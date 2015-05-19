.ifndef ::_ENTITIES_NPC_WALK_AND_TURN_H_
::_ENTITIES_NPC_WALK_AND_TURN_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

.include "../entities.h"
.include "../entity-physics.h"

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

	ENTITY_PHYSICS_STRUCT WalkAndTurnEntityStruct
		;; If zero moving left, else right
		walkLeftOnZero		.word

		;; Number of pixels ahead of the entity to check before ledge
		ledgeCheckOffset	.word

		;; If non-zero then the NPC cannot be stomped by the player
		invincible		.byte
	END_ENTITY_PHYSICS_STRUCT

	LABEL	FunctionsTable
ENDMODULE

.endif ; ::_ENTITIES_NPC_WALK_AND_TURN_H_

; vim: set ft=asm:

