.ifndef ::_ENTITIES_NPC_BAT_H_
::_ENTITIES_NPC_BAT_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

.include "../entities.h"
.include "../entity-physics.h"
.include "../entity-animation.h"


IMPORT_MODULE Npc_Bat

	.enum Npc_Bat_AnimationId
		HOVER_LEFT
		HOVER_RIGHT
		FLY_LEFT
		FLY_RIGHT
		COLLISION_PLAYER
	.endenum

	ENTITY_PHYSICS_STRUCT BatEntityStruct
		;; The number of pixels from the entity to the player before flying.
		threashold		.word

		;; The number of pixels to hover up and down
		;; (unsigned 8:8 fixed point)
		hoverHeight		.word

		;; The speed that the entity flys at (x Velocity)
		flyXVecl		.word

		;; The speed that the entity overs at (y Velocity)
		hoverYVecl		.word

		;  The fields below do not need to be set initialized.
		; -----------------------------------------------------

		;; Direction of flying
		flyLeftOnZero		.word

		;; Diection of hover
		hoverUpOnZero		.word

		;; Number of pixels currently flying up/down
		hoverPosition		.word

		;; Entity state.
		state			.word
	END_ENTITY_PHYSICS_STRUCT


	LABEL	FunctionsTable
ENDMODULE

.endif ; ::_ENTITIES_NPC_BAT_H_

; vim: set ft=asm:

