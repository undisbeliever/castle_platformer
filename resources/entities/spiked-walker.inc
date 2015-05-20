; ::TODO generate by program::

.global Entity_SpikedWalkerLeft
.global Entity_SpikedWalkerRight

.proc SpikedWalker


WALK_FRAME_DELAY	=  4
SLIDE_FRAME_DELAY	=  1
LAND_FRAME_DELAY	= 10
HURT_PLAYER_DELAY	= 60
DEATH_ANIMATION_DELAY	= 45

ENTITY_WIDTH = 12
ENTITY_HEIGHT = 14
ENTITY_XOFFSET = 6
ENTITY_YOFFSET = 7

ENTTY_PRIORITY = 2


.segment ENTITY_STATE_BANK

LABEL	Entity_SpikedWalkerLeft
	; WalkAndTurnEntityStruct
	.word	_Entity_SpikedWalkerLeft_End - Entity_SpikedWalkerLeft	; size
	.addr	Npc_WalkAndTurn__FunctionsTable		; functionsTable
	.byte	0, 0, 0					; xPos
	.byte	0, 0, 0					; yPos
	.word	ENTITY_WIDTH				; size_width
	.word	ENTITY_HEIGHT				; size_height
	.word	ENTITY_XOFFSET				; size_xOffset
	.word	ENTITY_YOFFSET				; size_yOffset
	.addr	.loword(Frame_WalkLeft0)		; metaSpriteFrame
	.word	0					; metaSpriteCharAttr
	.addr	AnimationTable				; animationTable
	.addr	0					; animationPC
	.word	0					; tileVramLocation
	.byte	Npc_WalkAndTurn_AnimationId::WALK_LEFT	; animationId
	.byte	0					; animationFrameDelay
	.word	0					; xVecl
	.word	0					; yVecl
	.addr	0					; standingTile
	.addr	0					; currentTileProperty
	.word	$0000					; walkLeftOnZero
	.word	8					; ledgeCheckOffset
	.byte	$FF					; invincible
_Entity_SpikedWalkerLeft_End:


LABEL	Entity_SpikedWalkerRight
	; WalkAndTurnEntityStruct
	.word	_Entity_SpikedWalkerRight_End - Entity_SpikedWalkerRight; size
	.addr	Npc_WalkAndTurn__FunctionsTable		; functionsTable
	.byte	0, 0, 0					; xPos
	.byte	0, 0, 0					; yPos
	.word	ENTITY_WIDTH				; size_width
	.word	ENTITY_HEIGHT				; size_height
	.word	ENTITY_XOFFSET				; size_xOffset
	.word	ENTITY_YOFFSET				; size_yOffset
	.addr	.loword(Frame_WalkRight0)		; metaSpriteFrame
	.word	0					; metaSpriteCharAttr
	.addr	AnimationTable				; animationTable
	.addr	0					; animationPC
	.word	0					; tileVramLocation
	.byte	Npc_WalkAndTurn_AnimationId::WALK_RIGHT	; animationId
	.byte	0					; animationFrameDelay
	.word	0					; xVecl
	.word	0					; yVecl
	.addr	0					; standingTile
	.addr	0					; currentTileProperty
	.word	$FFFF					; walkLeftOnZero
	.word	8					; ledgeCheckOffset
	.byte	$FF					; invincible
_Entity_SpikedWalkerRight_End:


.segment ANIMATION_TABLE_BANK

AnimationTable:
	.byte	.bankbyte(Tiles)
	.addr	Tiles
	.byte	AnimationDmaTransferType::BLOCK
	.word	Tiles_End - Tiles
	.addr	Palette

	.addr	Animation_WalkLeft
	.addr	Animation_WalkRight
	.addr	Animation_SlideLeft
	.addr	Animation_SlideRight
	.addr	Animation_FallLeft
	.addr	Animation_FallRight
	.addr	Animation_LandLeft
	.addr	Animation_LandRight
	.addr	Animation_CollisionHurtPlayerLeft
	.addr	Animation_CollisionHurtPlayerRight
	.addr	Animation_DeathAnimationLeft
	.addr	Animation_DeathAnimationRight


.segment ANIMATION_PALETTE_BANK

Palette:
	.incbin "spiked-walker.clr", 2, 15 * 2


.segment "BANK2"

Tiles:
	.incbin "spiked-walker.4bpp"
Tiles_End:


.segment ANIMATION_BANK

Animation_WalkLeft:
_Animation_WalkLeft_Loop:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkLeft0
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	WALK_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkLeft1
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	WALK_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkLeft2
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	WALK_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkLeft3
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	WALK_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkLeft4
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	WALK_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkLeft5
	.byte	AnimationBytecode::GOTO
		.addr   _Animation_WalkLeft_Loop


Animation_WalkRight:
_Animation_WalkRight_Loop:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkRight0
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	WALK_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkRight1
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	WALK_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkRight2
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	WALK_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkRight3
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	WALK_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkRight4
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	WALK_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkRight5
	.byte	AnimationBytecode::GOTO
		.addr	_Animation_WalkRight_Loop


Animation_SlideLeft:
_Animation_SlideLeft_Loop:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkLeft0
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	SLIDE_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkLeft1
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	SLIDE_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkLeft2
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	SLIDE_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkLeft3
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	SLIDE_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkLeft4
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	SLIDE_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkLeft5
	.byte	AnimationBytecode::GOTO
		.addr	_Animation_SlideLeft_Loop


Animation_SlideRight:
_Animation_SlideRight_Loop:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkRight0
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	SLIDE_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkRight1
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	SLIDE_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkRight2
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	SLIDE_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkRight3
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	SLIDE_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkRight4
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	SLIDE_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkRight5
	.byte	AnimationBytecode::GOTO
		.addr   _Animation_SlideRight_Loop


Animation_FallLeft:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_FallLeft
	.byte	AnimationBytecode::STOP


Animation_FallRight:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_FallRight
	.byte	AnimationBytecode::STOP



Animation_LandLeft:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_LandLeft
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	LAND_FRAME_DELAY
	.byte	AnimationBytecode::STOP


Animation_LandRight:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_LandRight
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	LAND_FRAME_DELAY
	.byte	AnimationBytecode::STOP



Animation_CollisionHurtPlayerLeft:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_HurtPlayerLeft
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	HURT_PLAYER_DELAY
	.byte	AnimationBytecode::STOP


Animation_CollisionHurtPlayerRight:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_HurtPlayerRight
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	HURT_PLAYER_DELAY
	.byte	AnimationBytecode::STOP



Animation_DeathAnimationLeft:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_DeadLeft
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	DEATH_ANIMATION_DELAY
	.byte	AnimationBytecode::STOP


Animation_DeathAnimationRight:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_DeadRight
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	DEATH_ANIMATION_DELAY
	.byte	AnimationBytecode::STOP




.segment METASPRITE_FRAME_BANK

Frame_WalkLeft0:
	.byte	1
		MetaSprite	-8, -8, 0, BIG, ENTTY_PRIORITY

Frame_WalkLeft1:
	.byte	1
		MetaSprite	-8, -8, 2, BIG, ENTTY_PRIORITY

Frame_WalkLeft2:
	.byte	1
		MetaSprite	-8, -8, 4, BIG, ENTTY_PRIORITY

Frame_WalkLeft3:
	.byte	1
		MetaSprite	-8, -8, 6, BIG, ENTTY_PRIORITY

Frame_WalkLeft4:
	.byte	1
		MetaSprite	-8, -8, 8, BIG, ENTTY_PRIORITY

Frame_WalkLeft5:
	.byte	1
		MetaSprite	-8, -8, 10, BIG, ENTTY_PRIORITY


Frame_WalkRight0:
	.byte	1
		MetaSprite	-8, -8, 0, BIG, ENTTY_PRIORITY, MS_HFLIP

Frame_WalkRight1:
	.byte	1
		MetaSprite	-8, -8, 2, BIG, ENTTY_PRIORITY, MS_HFLIP

Frame_WalkRight2:
	.byte	1
		MetaSprite	-8, -8, 4, BIG, ENTTY_PRIORITY, MS_HFLIP

Frame_WalkRight3:
	.byte	1
		MetaSprite	-8, -8, 6, BIG, ENTTY_PRIORITY, MS_HFLIP

Frame_WalkRight4:
	.byte	1
		MetaSprite	-8, -8, 8, BIG, ENTTY_PRIORITY, MS_HFLIP

Frame_WalkRight5:
	.byte	1
		MetaSprite	-8, -8, 10, BIG, ENTTY_PRIORITY, MS_HFLIP


Frame_FallLeft:
	.byte	1
		MetaSprite	-8, -8, 12, BIG, ENTTY_PRIORITY

Frame_FallRight:
	.byte	1
		MetaSprite	-8, -8, 12, BIG, ENTTY_PRIORITY, MS_HFLIP


Frame_LandLeft:
Frame_HurtPlayerLeft:
Frame_DeadLeft:
	.byte	1
		MetaSprite	-8, -8, 14, BIG, ENTTY_PRIORITY


Frame_LandRight:
Frame_HurtPlayerRight:
Frame_DeadRight:
	.byte	1
		MetaSprite	-8, -8, 14, BIG, ENTTY_PRIORITY, MS_HFLIP


.endproc

; vim: ft=asm:

