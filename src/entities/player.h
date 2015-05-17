.ifndef ::_ENTITIES_PLAYER_H_
::_ENTITIES_PLAYER_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

.include "../entities.h"
.include "../entity-physics.h"

ENTITY_PHYSICS_STRUCT PlayerEntityStruct
	;; Number of enemies jumped ontop of before hitting the ground.
	nEnemysJumpedOnBeforeTouchingGround	.word
END_ENTITY_STRUCT


IMPORT_MODULE Player
	LABEL	InitState

	;; Tests to see if the player collision is the player jumping
	;; on the top half of an NPC.
	;;
	;; The top half of the NPC is the area above the NPC's yPos,
	;; and is `npc->size_yOffset` pixels tall.
	;;
	;; If so, then the player rebounds off the NPC and
	;; `nEnemysJumpedOnBeforeTouchingGround` counter is increased.
	;;
	;; REQUIRE: 16 bit A, 16 bit Index, DB = $7E
	;; INPUT: dp = npc the player has jumped on
	;; OUTPUT: Carry set if NPC is NOT jumped on, Carry clear if enemy jumped on.
	ROUTINE TestCollisionIsJumpingOnANpc

	;; Updates the map's position, depending on the players position
	;; REQUIRE: 16 bit A, 16 bit Index, DB = $7E or access shadow
	;; INPUT: DP = player
	ROUTINE	SetScreenPosition
ENDMODULE

.endif ; ::_ENTITIES_PLAYER_H_

; vim: set ft=asm:

