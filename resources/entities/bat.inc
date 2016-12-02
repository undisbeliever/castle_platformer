
.global Entity_Bat

.proc Bat


HOVER_FRAME_DELAY	=  8
FLY_FRAME_DELAY		=  6

ENTITY_WIDTH = 14
ENTITY_HEIGHT = 6
ENTITY_XOFFSET = 7
ENTITY_YOFFSET = 3

ENTTY_PRIORITY = 3


.segment ENTITY_STATE_BANK

LABEL	Entity_Bat
	; BatEntityStruct
	.word	_Entity_Bat_End - Entity_Bat		; size
	.addr	Npc_Bat__FunctionsTable			; functionsTable
	.byte	0, 0, 0					; xPos
	.byte	0, 0, 0					; yPos
	.word	ENTITY_WIDTH				; size_width
	.word	ENTITY_HEIGHT				; size_height
	.word	ENTITY_XOFFSET				; size_xOffset
	.word	ENTITY_YOFFSET				; size_yOffset
	.addr	.loword(Frame_Left0)			; metaSpriteFrame
	.word	0					; metaSpriteCharAttr
	.addr	AnimationTable				; animationTable
	.addr	0					; animationPC
	.addr	0					; tileVramLocation
	.byte	Npc_Bat_AnimationId::HOVER_LEFT		; animationId
	.byte	0					; animationFrameDelay
	.word	0					; xVecl
	.word	0					; yVecl
	.addr	0					; standingTile
	.addr	0					; currentTileProperty
	.word	16					; threashold
	.word	32 * 256				; hoverHeight
	.word	$0120					; flyXVecl
	.word	$0080					; hoverYVecl
_Entity_Bat_End:


.segment ANIMATION_TABLE_BANK

AnimationTable:
	.byte	.bankbyte(Tiles)
	.addr	Tiles
	.byte	AnimationDmaTransferType::BLOCK
	.word	Tiles_End - Tiles
	.addr	Palette

	.addr	Animation_HoverLeft
	.addr	Animation_HoverRight
	.addr	Animation_FlyLeft
	.addr	Animation_FlyRight
	.addr	Animation_CollisionPlayer


.segment ANIMATION_PALETTE_BANK

Palette:
	.incbin "bat.clr", 2, 15 * 2


.segment "BANK2"

Tiles:
	.incbin "bat.4bpp"
Tiles_End:


.segment ANIMATION_BANK

Animation_HoverLeft:
_Animation_HoverLeft_Loop:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Left0
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	HOVER_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Left1
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	HOVER_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Left2
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	HOVER_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Left3
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	HOVER_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Left2
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	HOVER_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Left1
	.byte	AnimationBytecode::GOTO
		.addr   _Animation_HoverLeft_Loop


Animation_HoverRight:
_Animation_HoverRight_Loop:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Right0
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	HOVER_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Right1
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	HOVER_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Right2
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	HOVER_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Right3
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	HOVER_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Right2
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	HOVER_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Right1
	.byte	AnimationBytecode::GOTO
		.addr	_Animation_HoverRight_Loop


Animation_FlyLeft:
_Animation_FlyLeft_Loop:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Left0
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	FLY_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Left1
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	FLY_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Left2
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	FLY_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Left3
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	FLY_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Left2
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	FLY_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Left1
	.byte	AnimationBytecode::GOTO
		.addr	_Animation_FlyLeft_Loop


Animation_FlyRight:
_Animation_FlyRight_Loop:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Right0
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	FLY_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Right1
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	FLY_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Right2
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	FLY_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Right3
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	FLY_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Right2
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	FLY_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Right1
	.byte	AnimationBytecode::GOTO
		.addr   _Animation_FlyRight_Loop


Animation_CollisionPlayer:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_CollisionPlayer


.segment METASPRITE_FRAME_BANK


Frame_Left0:
	.byte	1
		MetaSprite	-8,  -3, 0, BIG, ENTTY_PRIORITY, MS_HFLIP

Frame_Left1:
	.byte	1
		MetaSprite	-8,  -5, 2, BIG, ENTTY_PRIORITY, MS_HFLIP

Frame_Left2:
	.byte	1
		MetaSprite	-8, -11, 4, BIG, ENTTY_PRIORITY, MS_HFLIP

Frame_Left3:
	.byte	1
		MetaSprite	-8, -11, 6, BIG, ENTTY_PRIORITY, MS_HFLIP

Frame_Right0:
	.byte	1
		MetaSprite	-8,  -3, 0, BIG, ENTTY_PRIORITY

Frame_Right1:
	.byte	1
		MetaSprite	-8,  -5, 2, BIG, ENTTY_PRIORITY

Frame_Right2:
	.byte	1
		MetaSprite	-8, -11, 4, BIG, ENTTY_PRIORITY

Frame_Right3:
	.byte	1
		MetaSprite	-8, -11, 6, BIG, ENTTY_PRIORITY


Frame_CollisionPlayer:
	.byte	2
		MetaSprite	-16, -8, 8, BIG, ENTTY_PRIORITY
		MetaSprite	 -1, -8, 8, BIG, ENTTY_PRIORITY, MS_HFLIP
		
.endproc

; vim: ft=asm:

