
.global Entity_Stomper

.proc Stomper

ON_GROUND_FRAME_DELAY	= 60


ENTITY_WIDTH = 30
ENTITY_HEIGHT = 30
ENTITY_XOFFSET = 15
ENTITY_YOFFSET = 15

ENTTY_PRIORITY = 2


.segment ENTITY_STATE_BANK

	; StomperEntityStruct
LABEL	Entity_Stomper
	.word	Entity_Stomper_End - Entity_Stomper	; size
	.addr	Npc_Stomper__FunctionsTable		; functionsTable
	.byte	0, 0, 0					; xPos
	.byte	0, 0, 0					; yPos
	.word	ENTITY_WIDTH				; size_width
	.word	ENTITY_HEIGHT				; size_height
	.word	ENTITY_XOFFSET				; size_xOffset
	.word	ENTITY_YOFFSET				; size_yOffset
	.addr	Frame_Waiting				; metaSpriteFrame
	.word	0					; metaSpriteCharAttr
	.addr	AnimationTable				; animationTable
	.addr	0					; animationPC
	.word	0					; tileVramLocation
	.byte	Npc_Stomper_AnimationId::WAITING	; animationId
	.byte	0					; animationFrameDelay
	.word	0					; xVecl
	.word	0					; yVecl
	.addr	0					; standingTile
	.addr	0					; currentTileProperty
	.word	40					; threashold (pixels)
	.word	128					; raiseSpeed (in 1/256 pixels/frame)
Entity_Stomper_End:


.segment ANIMATION_TABLE_BANK

AnimationTable:
	.byte	.bankbyte(Tiles)
	.addr	Tiles
	.byte	AnimationDmaTransferType::TWO_ROWS_LEFT
	.word	(Tiles_End - Tiles) / 2
	.addr	Palette

	.addr	Animation_Waiting
	.addr	Animation_NoticedPlayer
	.addr	Animation_Falling
	.addr	Animation_OnGround
	.addr	Animation_Raising
	.addr	Animation_CollisionPlayer


.segment ANIMATION_PALETTE_BANK

Palette:
	.incbin "stomper.clr", 2, 15 * 2


.segment "BANK2"

Tiles:
	.incbin "stomper.4bpp"
Tiles_End:


.segment ANIMATION_BANK

Animation_Waiting:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Waiting
	.byte	AnimationBytecode::STOP

Animation_NoticedPlayer:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_NoticedPlayer
	.byte	AnimationBytecode::STOP

Animation_Falling:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Falling
	.byte	AnimationBytecode::STOP


Animation_OnGround:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_OnGround
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	ON_GROUND_FRAME_DELAY
	.byte	AnimationBytecode::STOP


Animation_Raising:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_OnGround
	.byte	AnimationBytecode::STOP


Animation_CollisionPlayer:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_CollisionPlayer
	.byte	AnimationBytecode::STOP


.segment METASPRITE_FRAME_BANK


Frame_Waiting:
	.byte	4
		MetaSprite	-16, -16, 0, BIG, ENTTY_PRIORITY, MS_HFLIP | MS_VFLIP
		MetaSprite	  0, -16, 2, BIG, ENTTY_PRIORITY, MS_HFLIP | MS_VFLIP
		MetaSprite	-16,   0, 4, BIG, ENTTY_PRIORITY, MS_HFLIP | MS_VFLIP
		MetaSprite	  0,   0, 6, BIG, ENTTY_PRIORITY, MS_HFLIP | MS_VFLIP


Frame_NoticedPlayer:
Frame_Falling:
Frame_OnGround:
Frame_Raising:
Frame_CollisionPlayer:
	.byte	4
		MetaSprite	-16, -16, 0, BIG, ENTTY_PRIORITY
		MetaSprite	  0, -16, 2, BIG, ENTTY_PRIORITY
		MetaSprite	-16,   0, 4, BIG, ENTTY_PRIORITY
		MetaSprite	  0,   0, 6, BIG, ENTTY_PRIORITY

.endproc

; vim: ft=asm:

