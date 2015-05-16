.ifndef ::_ENTITIES_PLAYER_H_
::_ENTITIES_PLAYER_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

.include "../entities.h"
.include "../entity-physics.h"

ENTITY_PHYSICS_STRUCT PlayerEntityStruct
END_ENTITY_STRUCT


IMPORT_MODULE Player
	LABEL	InitState

	;; Called when the player jumps and on an NPC.
	;; Player's yVecl increases.
	;; REQUIRE: 16 bit A, 16 bit Index, DB = $7E
	;; INPUT: dp = npc the player has jumped on
	ROUTINE JumpOnNpc

	;; Updates the map's position, depending on the players position
	;; REQUIRE: 16 bit A, 16 bit Index, DB = $7E or access shadow
	;; INPUT: DP = player
	ROUTINE	SetScreenPosition
ENDMODULE

.endif ; ::_ENTITIES_PLAYER_H_

; vim: set ft=asm:

