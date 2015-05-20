.ifndef ::_ENTITIES_NPC_STOMPER_H_
::_ENTITIES_NPC_STOMPER_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

.include "../entities.h"
.include "../entity-physics.h"
.include "../entity-animation.h"


ENTITY_PHYSICS_STRUCT StomperEntityStruct
	;; The number of pixels from the entity to the player before stomping.
	threashold		.word

	;; The number of frames to wait before raising.
	stompDelay		.word

	;; The speed in which the entity raises
	;; 1:7:8 signed fixed point. (1/256 pixels/frame)
	raiseSpeed		.word

	;  The fields below do not need to be set initialized.
	; -----------------------------------------------------

	;; Origional starting height
	startingYpos		.word

	;; Entity state.
	state			.word

	;; Current counter for the wait state
	frameWait		.word
END_ENTITY_PHYSICS_STRUCT


;; The Npc_Stomper emulates the Thwomps from Super Mario World.
IMPORT_MODULE Npc_Stomper
	LABEL	InitState
ENDMODULE

.endif ; ::_ENTITIES_NPC_STOMPER_H_

; vim: set ft=asm:
