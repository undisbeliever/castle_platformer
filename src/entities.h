.ifndef ::_ENTITIES_H_
::_ENTITIES_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

.struct EntitySizeStruct
	;; width of the entity in pixels
	width			.word
	;; height of the entity in pixels
	height			.word

	;; pixels from entity->xPos to entity->left
	;; (always positive)
	xOffsetLeft		.word
	;; pixels from entity->yPos to entity->top
	;; (always positive)
	yOffsetTop		.word

	;; ::SHOULDDO decide if this is necessary - should I save 4 bytes?::

	;; pixels from entity->xPos to entity->right
	;; (width - xOffsetLeft)
	; exists for speed: saves 7/17/21 cycles on physics
	xOffsetRight		.word
	;; pixels from entity->yPos to entity->bottom
	;; (height - yOffsetTop)
	; exists for speed: saves 7/17/21 cycles on physics
	yOffsetBottom		.word
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
	size_xOffsetLeft	.word
	size_yOffsetTop		.word
	size_xOffsetRight	.word
	size_yOffsetBottom	.word

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

