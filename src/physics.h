.ifndef ::_PHYSICS_H_
::_PHYSICS_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

.struct MetaTilePropertyStruct
	;; Type of tile.
	;;
	;; Non-Zero if the tile is solid.
	;; If 0 then the tile is not solid.
	;; If MSB (bit 15) is set then the tile is a one way platform.
	type			.word
	;; Friction applied to the entity when standing on the tile
	;; 1:7:8 signed fixed point
	friction		.word
	;; Walking acceleration when standing on the tile.
	;; 1:7:8 signed fixed point
	walkAcceleration	.word
	;; Minimum (negative) velocity when walking left
	;; 1:7:8 signed fixed point
	minimumXVelocity	.word
	;; Maximum (positive) velocity when walking right
	;; 1:7:8 signed fixed point
	maximumXVelocity	.word
	;; Jumping velocity, if 0 then the player cannot jump.
	;; 1:7:8 signed fixed point
	jumpingVelocity		.word
.endstruct

.global MetaTilePropertyBank:zp


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

	;; The address of the tileproperty of the tile underneath the entity if it is standing on a tile.
	;; 0 (NULL) if floating
	standingTile		.addr

	;; The address of the tileproperty that the entity is on.
	;; If the entity is standing, it set to tile the entity is standing on.
	;; If the entity is not standing, it is entity's top-left tile. 
	currentTile		.addr

	;; pointer to the MetaSpriteData within `MetaSpriteLayoutBank`
	metaSpriteFrame		.addr
	;; The CharAttr offset of the MetaSprite data.
	metaSpriteCharAttr	.word
.endstruct


IMPORT_MODULE Physics

	;; Table that points to the MetaTilePropertyStruct for each metatile.
	;; Must be set before calling.
	.global	Physics__metaTilePropertyTable : far

	;; The level's gravity.
	;; Must be set before using this module.
	.global Physics__gravity : far

	;; Updates the entity's physics
	;; REQUIRE: 16 bit A, 16 bit Index, DB = $7E
	;; INPUT: DP - EntityStruct location
	ROUTINE ProcessEntity
ENDMODULE

.endif ; ::_PHYSICS_H_

; vim: set ft=asm:

