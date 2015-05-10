;; Entity storage and management.

.ifndef ::_ENTITIES_H_
::_ENTITIES_H_ = 1

.setcpu "65816"
.include "entity.h"

; ::SHOULDDO make configurable::
N_ACTIVE_NPCS = 12
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

	;; Proceses all of the entities.
	;; REQUIRE: 16 bit A, 16 bit Index, DB = $7E
	ROUTINE	Process

	;; Render all of the entities with metatiles.
	;; REQUIRE: 8 bit A, 16 bit Index, DB access shadow ram
	ROUTINE	Render

ENDMODULE

.endif ; ::_ENTITIES_H_

; vim: set ft=asm:

