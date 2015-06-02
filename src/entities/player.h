.ifndef ::_ENTITIES_PLAYER_H_
::_ENTITIES_PLAYER_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

.include "../entities.h"
.include "../entity-physics.h"


IMPORT_MODULE Player
	.enum Player_AnimationId
		STAND_LEFT
		STAND_RIGHT
		WALK_LEFT
		WALK_RIGHT
		SLIDE_LEFT
		SLIDE_RIGHT
		JUMP_LEFT
		JUMP_RIGHT
		FALL_LEFT
		FALL_RIGHT
		DEAD
	.endenum

	ENTITY_PHYSICS_STRUCT PlayerEntityStruct
		;; Direction the player is facing.
		;; if zero then facing left.
		facingLeftOnZero			.word

		;; Number of enemies jumped ontop of before hitting the ground.
		nEnemysJumpedOnBeforeTouchingGround	.word
	END_ENTITY_STRUCT

	LABEL	FunctionsTable

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


	;; Kills the player.
	;; Sets the gamestate to DEAD, player animation to DEAD
	;;
	;; REQUIRE: 16 bit A, 16 bit Index, DB = $7E
	;; INPUT: dp = npc that killed the player.
	ROUTINE Kill

ENDMODULE

.endif ; ::_ENTITIES_PLAYER_H_

; vim: set ft=asm:

