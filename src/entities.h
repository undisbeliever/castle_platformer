;; Entity storage and management.
;;
;; ::TODO details::
;; 	* Uses FILO linked lists.

.ifndef ::_ENTITIES_H_
::_ENTITIES_H_ = 1

.setcpu "65816"
.include "entity.h"

; ::SHOULDDO make configurable::

;; NPC active window width, must be > {256 + (max entity width + max entity xvecl) * 2}
NPC_ACTIVE_WIDTH = 512
;; NPC active window height, must be > {224 + (max entity hight + max entity yvecl) * 2}
NPC_ACTIVE_HEIGHT = 384

N_NPCS = 64
N_PROJECTILES = 6

.define ENTITY_STATE_BANK "BANK1"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

IMPORT_MODULE Entities
	;; Player struct allocation
	BYTE	player, ENTITY_MALLOC

	;; Initilisation parameter passed to entity->Init when creating new entity.
	WORD	parameter

	;; Initializes the entity pools to 0
	;; REQUIRE: DB access shadow RAM
	ROUTINE Init

	;; Initializes the player entity
	;; REQUIRE: 16 bit A, 16 bit X, DB = $7E
	;; INPUT:
	;;	A - entity state address within ENTITY_STATE_BANK
	;;	X - entity x Position
	;;	Y - entity y Position
	;;	Entities__parameter - the parameter to pass to entity->Init
	ROUTINE	NewPlayer

	;; Initializes a new NPC entity
	;; REQUIRE: 16 bit A, 16 bit X, DB = $7E
	;; INPUT:
	;;	A - entity state address within ENTITY_STATE_BANK
	;;	X - entity x Position
	;;	Y - entity y Position
	;;	Entities__parameter - the parameter to pass to entity->Init
	ROUTINE	NewNpc

	;; Initializes a new player projectile entity
	;; REQUIRE: 16 bit A, 16 bit X, DB = $7E
	;; INPUT:
	;;	A - entity state address within ENTITY_STATE_BANK
	;;	X - entity x Position
	;;	Y - entity y Position
	;;	Entities__parameter - the parameter to pass to entity->Init
	ROUTINE	NewProjectile

	;; Proceses all of the entities.
	;;
	;; First stage of the Entity processing loop.
	;;
	;; This routine:
	;;	* Processes the player.
	;;	* Processes the Projectile's Process routine.
	;;	* Processes each NPC:
	;;		* Calls the NPC->Process routine.
	;;		* Checks for a collison between the NPC and the player,
	;;		  if there is one calls NPC->CollisionPlayer
	;;		* Checks for a collision between the NPC and the player
	;;		  projectiles. If there is one calls NPC->CollisionProjectle (::TODO this functionality::)
	;;
	;; REQUIRE: 16 bit A, 16 bit Index, DB = $7E
	ROUTINE	Process

	;; Renders all of the entities with metasprites.
	;;
	;; This routine:
	;;	* Dislays the player's
	;;	* Displays all of the Projectiles.
	;;	* Displays all of the NPCs
	;;
	;; REQUIRE: 8 bit A, 16 bit Index, DB = $7E
	ROUTINE	Render

ENDMODULE

.endif ; ::_ENTITIES_H_

; vim: set ft=asm:

