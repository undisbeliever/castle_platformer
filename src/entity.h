.ifndef ::_ENTITY_H_
::_ENTITY_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

; ::SHOULDO make configurable::
MAX_ENTITY_SIZE = 64

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
		;; Next entity in the linked list.
		;; If 0 then this is the last entity in the linked list.
		nextEntity		.addr

		;; location of the NpcEntityFunctionsTable/ProjectileEntityFunctionsTable/ParticleFunctionsTable for this entity.
		;; if 0 then the entity is considered inactive and will be removed from
		;; the linked list.
		functionsTable		.addr

		;; xPos - 16:8 unsigned fixed point
		xPos			.res 3
		;; yPos - 16:8 unsigned fixed point
		yPos			.res 3

		; ::ANNOY must match EntitySizeStruct::
		size_width		.word
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
	.assert .sizeof(__ENTITY_STRUCT_NAME) <= ::MAX_ENTITY_SIZE, error, .sprintf("ERROR: %s is too large (%d bytes max, %d bytes used)", .string(name), ::MAX_ENTITY_SIZE, .sizeof(__ENTITY_STRUCT_NAME))
	.undefine __ENTITY_STRUCT_NAME
.endmacro

ENTITY_STRUCT EntityStruct
END_ENTITY_STRUCT

.endif ; ::_ENTITY_H_

; vim: set ft=asm:

