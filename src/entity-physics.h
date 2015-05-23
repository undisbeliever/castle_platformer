.ifndef ::_ENTITY_PHYSICS_H_
::_ENTITY_PHYSICS_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

.include "entity.h"
.include "entity-animation.h"

.include "routines/metatiles/metatiles-1x16.h"

;; Maximum Y velocity (prevents fall through walls)
MAX_Y_VECLOCITY = 10 * 256

DEFAULT_GRAVITY = 40		; Acceleration due to gravity in 1/256 pixels per frame per frame
;; How much less gravity the entity experiences when holding the jump button
GRAVITY_JUMP_HOLD = 20
;; Fraction of Xvecl is added to the jump.
;; (`yVecl -= xVecl / JUMP_XVECL_FRACTIONAL`)
JUMP_XVECL_FRACTIONAL = 4


.struct MetaTileFunctionsTable
	;; Called when the player is standing on a tile
	;; REGISTERS: 16 bit A, 16 bit Index, DB = $7E
	;; INPUT: ZP - EntityPhysicsStruct address
	PlayerStand		.addr

	;; Called when the player is touching a tile
	;; REGISTERS: 16 bit A, 16 bit Index, DB = $7E
	;; INPUT: ZP - EntityPhysicsStruct address
	PlayerTouch		.addr
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
	minimumWalkXVelocity	.word
	;; Maximum (positive) velocity when walking right
	;; 1:7:8 signed fixed point
	maximumWalkXVelocity	.word
	;; Minimum (negative) velocity when running left
	;; 1:7:8 signed fixed point
	minimumXVelocity	.word
	;; Maximum (positive) velocity when running right
	;; 1:7:8 signed fixed point
	maximumXVelocity	.word
	;; Jumping velocity, if 0 then the player cannot jump.
	;; 1:7:8 signed fixed point
	jumpingVelocity		.word
.endstruct

.enum EntityPhysicsStatusBits
	STANDING 	= $80
	PLATFORM 	= $40
	HEAD_COLLISION	= $04
	RIGHT_COLLISION	= $02
	LEFT_COLLISION	= $01
.endenum

.global MetaTilePropertyBank:zp


;; Animated Entity class that supports physics and tile collisions.
;;
;; This class adds:
;;	* Velocity
;;	* Collisions with tile map
;;	* Varying physics constants (friction, acceleration) depending on the tile its standing on or in front of.
.macro ENTITY_PHYSICS_STRUCT name
	ENTITY_ANIMATION_STRUCT name
		;; xVecl - 1:7:8 signed fixed point
		xVecl			.res 2
		;; xVecl - 1:7:8 signed fixed point
		yVecl			.res 2

		;; The address of the tile within the map that the entity is standing on.
		;; 0 (NULL) if floating.
		standingTile		.addr

		;; The address of the tileproperty that the entity is on.
		;; If the entity is standing, it set to tile the entity is standing on.
		;; If the entity is not standing, it is entity's top-left tile. 
		currentTileProperty	.addr
.endmacro
.define END_ENTITY_PHYSICS_STRUCT END_ENTITY_ANIMATION_STRUCT

ENTITY_PHYSICS_STRUCT EntityPhysicsStruct
END_ENTITY_PHYSICS_STRUCT


IMPORT_MODULE EntityPhysics

	;; Table that points to the MetaTilePropertyStruct for each metatile.
	;; Must be set before calling  `EntityPhysicsWithCollisions` or
	;; `EntityPhysicsWithCollisionsNoGravity`
	;; ACCESSED: DB = $7E
	ADDR	metaTilePropertyTable, N_METATILES

	;; The level's gravity.
	;; Must be set before using this module.
	;; ACCESSED: DB = $7E
	WORD	gravity

	;; MetaTileFunctionsTable location of the tile that the entity touched.
	;; Set by `EntityPhysicsWithCollisions` and `EntityPhysicsWithCollisionsNoGravity`
	;; If 0 then all tiles it touched have no functions table.
	;;
	;; ACCESSED: DB = $7E
	ADDR entityTouchTileFunctionPtr

	;; Status flags to tell the AI the state of the collisions
	;; between the entity and the tilemap.
	;;
	;; The value of the bits is defined by `EntityPhysicsStatusBits`
	;;
	;; Set by `EntityPhysicsWithCollisions`
	;;
	;; ACCESSED: DB = $7E
	BYTE status


	;; Preforms physics and collisions for a given entity.
	;;	* Adds Gravity
	;;	* Checks collisisons
	;;	* Sets `Entity::currentTile` to the MetaTilePropertyStruct of
	;;	  the tile the entity is in front of
	;;	* Sets `Entity::standingTile` to NULL (0) if entity is floating
	;;	* Sets `Entity::standingTile` to the MetaTilePropertyStruct of
	;;	  the tile the entity is standing on
	;;	* Sets `EntityPhysics__entityTouchTileFunctionPtr` to the MetaTileFunctionsTable
	;;	  location of last tile touched that has a functions table.
	;;	* Sets the `EntityPhysics__status` `EntityPhysicsStatusBits` bits if a
	;;	  collision occoured.
	;;
	;; REQUIRE: 16 bit A, 16 bit Index, DB = $7E
	;; INPUT: DP - entity location (must be a subclass of EntityPhysicsStruct)
	ROUTINE EntityPhysicsWithCollisions

	;; Preforms physics with collisions, but no gravity for the given entity
	;; Does the same as `EntityPhysicsWithCollisions` but doesn't add gravity to `z:EntityStruct::yPos`
	;; REQUIRE: 16 bit A, 16 bit Index, DB = $7E
	;; INPUT: DP - entity address (must be a subclass of EntityPhysicsStruct)
	ROUTINE EntityPhysicsWithCollisionsNoGravity

	;; Updates an entities position, from its velocity, there are no collisions.
	;; REQUIRE: 16 bit A, 16 bit Index, DB = $7E
	;; INPUT: DP - entity address (must be a subclass of EntityPhysicsStruct)
	ROUTINE EntitySimplePhysics



	;; Move the entity depending on joypad.
	;;
	;; Will decrement the player's yVecl if the JOY_JUMP button is
	;; depressed and player is not standing on ground.
	;;
	;; This function would not work if Gravity is removed from the player.
	;;
	;; REQUIRE: 16 bit A, 16 bit Index, DB = $7E
	;; INPUT:
	;;      DP - entity address (must be a subclass of EntityPhysicsStruct)
	;;	A - Joypad data. (16 bit)
	ROUTINE MoveEntityWithController

	;; Sets the player's yVeclity to their jumping velocity.
	;;
	;; The jumping velocity is combined with the `currentTileProperty`'s
	;; `jumpingVelocity` and the delta of the entitie's xVecl.
	;;
	;; REQUIRE: 16 bit A, 16 bit Index, DB = $7E
	;; INPUT: DP - entity adress (must be a subclass of EntityPhysicsStruct)
	ROUTINE Jump
ENDMODULE

.endif ; ::_ENTITY_PHYSICS_H_

; vim: set ft=asm:

