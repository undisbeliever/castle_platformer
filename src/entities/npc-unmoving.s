
.include "npc-unmoving.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "player.h"
.include "../entities.h"
.include "../entity.h"
.include "../gameloop.h"

.include "routines/metasprite.h"

ENTITY_WIDTH = 32
ENTITY_HEIGHT = 16
ENTITY_XOFFSET = 16
ENTITY_YOFFSET = 8

.define UES UnmovingEntityStruct
ENTITY_STRUCT UnmovingEntityStruct
	;; If non-zero then the NPC cannot kill the player
	backgroundNpc	.word
END_ENTITY_STRUCT


MODULE Npc_Unmoving

.rodata
LABEL	FunctionsTable
	.addr	Init
	.addr	Activated
	.addr	Inactive
	.addr	Process
	.addr	CollisionPlayer


; DP = entity
; DB = $7E
; A = If non-zero then the NPC cannot kill the player.
.A16
.I16
ROUTINE Init
	STA	z:UES::backgroundNpc
	RTS


; DP = entity
; DB = $7E
.A16
.I16
ROUTINE Activated
ROUTINE Inactive
	RTS


; DP = entity
; DB = $7E
; OUT: c set if entity still alive
.A16
.I16
ROUTINE Process
	SEC
	RTS


; DP = entity
; DB = $7E
; OUT: c set if entity still alive
.A16
.I16
ROUTINE	CollisionPlayer
	LDA	z:UES::backgroundNpc
	IF_ZERO
		JSR	Player__Kill
	ENDIF

	SEC
	RTS


.segment ENTITY_STATE_BANK

	; EntityStruct
LABEL	InitState
	.word	InitState_End - InitState	; size
	.addr	.loword(FunctionsTable)		; functionsTable
	.byte	0, 0, 0				; xPos
	.byte	0, 0, 0				; yPos
	.word	ENTITY_WIDTH			; size_width
	.word	ENTITY_HEIGHT			; size_height
	.word	ENTITY_XOFFSET			; size_xOffset
	.word	ENTITY_YOFFSET			; size_yOffset
	.word	.loword(ExampleMetaSpriteFrame)	; metaSpriteFrame
	.word	0				; metaSpriteCharAttr
InitState_End:


.segment "BANK1"

;; TEST example data::

ExampleMetaSpriteFrame:
	.byte	2
	.byte	.lobyte(-16)
	.byte	.lobyte(-8)
	.word	2 << OAM_CHARATTR_ORDER_SHIFT
	.byte	$FF
	.byte	.lobyte(0)
	.byte	.lobyte(-8)
	.word	2 << OAM_CHARATTR_ORDER_SHIFT
	.byte	$FF

ENDMODULE

