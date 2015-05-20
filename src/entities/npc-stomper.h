.ifndef ::_ENTITIES_NPC_STOMPER_H_
::_ENTITIES_NPC_STOMPER_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

.include "../entities.h"
.include "../entity-physics.h"
.include "../entity-animation.h"


;; The Npc_Stomper emulates the Thwomps from Super Mario World.
IMPORT_MODULE Npc_Stomper

	.enum Npc_Stomper_AnimationId
		WAITING
		NOTICED_PLAYER
		FALLING
		ON_GROUND
		RISING
		COLLISION_PLAYER
	.endenum

	ENTITY_PHYSICS_STRUCT StomperEntityStruct
		;; The number of pixels from the entity to the player before stomping.
		threashold		.word

		;; The speed in which the entity raises
		;; 1:7:8 signed fixed point. (1/256 pixels/frame)
		raiseSpeed		.word

		;  The fields below do not need to be set initialized.
		; -----------------------------------------------------

		;; Origional starting height
		startingYpos		.word

		;; Entity state.
		state			.word
	END_ENTITY_PHYSICS_STRUCT


	LABEL	FunctionsTable
ENDMODULE

.endif ; ::_ENTITIES_NPC_STOMPER_H_

; vim: set ft=asm:

