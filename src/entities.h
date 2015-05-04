.ifndef ::_ENTITIES_H_
::_ENTITIES_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

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

; ::DEBUG copied from asteroids::
.struct EntityStruct
	;; xPos - 16:8 unsigned fixed point
	xPos			.res 3
	;; yPos - 16:8 unsigned fixed point
	yPos			.res 3

	;; xVecl - 1:7:8 signed fixed point
	xVecl			.res 2
	;; xVecl - 1:7:8 signed fixed point
	yVecl			.res 2

	; ::ANNOY must match EntitySizeStruct::
	size_width		.word
	size_height		.word
	size_xOffset		.word
	size_yOffset		.word

	;; The address of the tile within the map that the entity is standing on.
	;; 0 (NULL) if floating.
	standingTile		.addr

	;; The address of the tileproperty that the entity is on.
	;; If the entity is standing, it set to tile the entity is standing on.
	;; If the entity is not standing, it is entity's top-left tile. 
	currentTileProperty	.addr

	;; pointer to the MetaSpriteData within `MetaSpriteLayoutBank`
	metaSpriteFrame		.addr
	;; The CharAttr offset of the MetaSprite data.
	metaSpriteCharAttr	.word
.endstruct


IMPORT_MODULE Entities

	;; Render the entities with metatiles.
	;; REQUIRE: 8 bit A, 16 bit Index, DB access registers
	ROUTINE	Render

ENDMODULE

.endif ; ::_ENTITIES_H_

; vim: set ft=asm:

