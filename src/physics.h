.ifndef ::_PHYSICS_H_
::_PHYSICS_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"


; ::DEBUG copied from asteroids::
.struct EntitySizeStruct
	width			.word
	height			.word

	tileWidth		.byte
	tileHeight		.byte
.endstruct

.global EntitySizeStructBank:zp

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

	;; The address of the tile the entity is standing on
	;; 0 (NULL) if floating
	standingTile		.addr

	;; pointer to the MetaSpriteData within `MetaSpriteLayoutBank`
	metaSpriteFrame		.addr
	;; The CharAttr offset of the MetaSprite data.
	metaSpriteCharAttr	.word
.endstruct


IMPORT_MODULE Physics

	;; Updates the entity's physics
	;; REQUIRE: 16 bit A, 16 bit Index, DB access registers
	;; INPUT: DP - EntityStruct location
	ROUTINE ProcessEntity
ENDMODULE

.endif ; ::_PHYSICS_H_

; vim: set ft=asm:

