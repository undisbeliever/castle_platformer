.ifndef ::_PHYSICS_H_
::_PHYSICS_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

.struct MetaTileFunctionsTable
	;; Called when the player is standing on a tile
	;; REGISTERS: 16 bit A, 16 bit Index, DB = $7E
	;; INPUT: ZP - entity
	PlayerStand		.addr
.endstruct

.struct MetaTilePropertyStruct
	;; Type of tile.
	;;
	;; Non-Zero if the tile is solid.
	;; If 0 then the tile is not solid.
	;; If MSB (bit 15) is set then the tile is a one way platform.
	type			.word
	;; Location of the `MetaTilePropertyStruct`
	;; If NULL (0) then the tile has no functions.
	functionsTable		.addr
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


IMPORT_MODULE Physics

	;; Table that points to the MetaTilePropertyStruct for each metatile.
	;; Must be set before calling.
	.global	Physics__metaTilePropertyTable : far

	;; The level's gravity.
	;; Must be set before using this module.
	.global Physics__gravity : far

	;; Preforms physics and collisions for a given entity.
	;;	* Adds Gravity
	;;	* Checks collisisons
	;;	* Sets `Entity::currentTile` to the MetaTilePropertyStruct of the tile the entity is in front of
	;;	* Sets `Entity::standingTile` to NULL (0) if entity is floating
	;;	* Sets `Entity::standingTile` to the MetaTilePropertyStruct of the tile the entity is standing on
	;;
	;; REQUIRE: 16 bit A, 16 bit Index, DB = $7E
	;; INPUT: DP - EntityStruct location
	ROUTINE EntityPhysicsWithCollisions

	;; Preforms physics with collisions, but no gravity for the given entity
	;; Does the same as `EntityPhysicsWithCollisions` but doesn't add gravity to `z:EntityStruct::yPos`
	;; REQUIRE: 16 bit A, 16 bit Index, DB = $7E
	;; INPUT: DP - EntityStruct Location
	ROUTINE EntityPhysicsWithCollisionsNoGravity

	;; Updates an entities position, from its velocity, there are no collisions.
	;; REQUIRE: 16 bit A, 16 bit Index, DB = $7E
	;; INPUT: DP - EntityStruct location
	ROUTINE EntitySimplePhysics

	;; Move the entity depending on joypad
	;; REQUIRE: 16 bit A, 16 bit Index, DB = $7E
	;; INPUT:
	;;	DP - EntityStrcct location
	;;	A - Joypad data. (16 bit)
	ROUTINE MoveEntityWithController
ENDMODULE

.endif ; ::_PHYSICS_H_

; vim: set ft=asm:

