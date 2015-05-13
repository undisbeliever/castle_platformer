.ifndef ::_ENTITY_H_
::_ENTITY_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

; ::SHOULDO make configurable::
ENTITY_MALLOC = 64

;; Function table for player entity
.struct PlayerEntityFunctionsTable
	;; Called on entity creation, after state is loaded.
	;; MUST NOT SET the Entity's `functionsTable` to NULL.
	;; REQUIRES: 16 bit A, 16 bit Index
	;; INPUT:
	;;	dp = EntityStruct address
	;;	A = parameter
	Init			.addr

	;; Called once per frame.
	;; May set the Entity's `functionsTable` to NULL to delete the entity.
	;; REQUIRES: 16 bit A, 16 bit Index
	;; INPUT: dp = EntityStruct address
	Process			.addr
.endstruct


;; Function table for NPC enities
.struct NpcEntityFunctionsTable
	;; Called on entity creation, after state is loaded.
	;; MUST NOT SET the Entity's `functionsTable` to NULL.
	;; REQUIRES: 16 bit A, 16 bit Index
	;; INPUT:
	;;	dp = EntityStruct address
	;;	A = parameter
	Init			.addr

	;; Called once per frame.
	;; May set the Entity's `functionsTable` to NULL to delete the entity.
	;; REQUIRES: 16 bit A, 16 bit Index
	;; INPUT: dp = EntityStruct address
	;; OUTPUT: Carry set if entity still alive
	Process			.addr

	;; Called when the player collides with the npc
	;; REQUIRES: 16 bit A, 16 bit Index
	;; INPUT: dp: EntityStruct NPC address
	;; OUTPUT: Carry set if entity still alive
	CollisionPlayer		.addr
.endstruct


;; Function table for player projectiles
.struct ProjectileEntityFunctionsTable
	;; Called on entity creation, after state is loaded.
	;; MUST NOT SET the Entity's `functionsTable` to NULL.
	;; REQUIRES: 16 bit A, 16 bit Index
	;; INPUT:
	;;	dp = EntityStruct address
	;;	A = parameter
	Init			.addr

	;; Called once per frame.
	;; May set the Entity's `functionsTable` to NULL to delete the entity.
	;; REQUIRES: 16 bit A, 16 bit Index
	;; INPUT: dp = EntityStruct address
	Process			.addr
.endstruct


;; Represents the AABB (Axis Aligned Bounding Box) of the entity
;; for physics and collisions.
.struct EntitySizeStruct
	;; width of the AABB in pixels
	width			.word
	;; height of the AABB in pixels
	height			.word

	;; pixel distance from leftmost position of AABB to xPos
	xOffset			.word
	;; pixel distance from topmost position of AABB to yPos
	yOffset			.word
.endstruct

;; The base class for all entities.
;; all entities used by entities module MUST subclass ENTITY_STRUCT.
;;
;; This class supports:
;;	* The entity's position
;;	* The entity's size and offset for collision testing
;;	* The entity's metasprite frame and attributes for displaying on screen
.macro	ENTITY_STRUCT	name
	.define __ENTITY_STRUCT_NAME name

	.struct name
		.union
			;; Next entity in the linked list.
			;; If 0 then this is the last entity in the linked list.
			nextEntity		.addr

			;; Size of the entity in the ROM
			;; this field is only used when loading the entity's state
			;; from ROM into RAM.
			sizeInBytes		.word
		.endunion

		;; location of the NpcEntityFunctionsTable/ProjectileEntityFunctionsTable/ParticleFunctionsTable for this entity.
		;; if 0 then the entity is considered inactive and will be removed from
		;; the linked list.
		functionsTable		.addr

		;; xPos - 1:15:8 signed fixed point
		xPos			.res 3
		;; yPos - 1:15:8 signed fixed point
		yPos			.res 3

		;; Size of the entity.
		.union
			size		.word
			; ::ANNOY cannot access nested structs easily::
			; ::: MUST match EntitySizeStruct::
			size_width	.word
		.endunion
		size_height		.word
		size_xOffset		.word
		size_yOffset		.word

		;; pointer to the MetaSpriteData within `MetaSpriteLayoutBank`
		metaSpriteFrame		.addr
		;; The CharAttr offset of the MetaSprite data.
		metaSpriteCharAttr	.word
.endmacro

.macro END_ENTITY_STRUCT
	.endstruct
	.assert .sizeof(__ENTITY_STRUCT_NAME) <= ::ENTITY_MALLOC, error, .sprintf("ERROR: %s is too large (%d bytes max, %d bytes used)", .string(name), ::ENTITY_MALLOC, .sizeof(__ENTITY_STRUCT_NAME))
	.undefine __ENTITY_STRUCT_NAME
.endmacro

ENTITY_STRUCT EntityStruct
END_ENTITY_STRUCT

.endif ; ::_ENTITY_H_

; vim: set ft=asm:

