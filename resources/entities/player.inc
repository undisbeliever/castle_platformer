
.global Entity_Player

.proc Player

ENTITY_WIDTH = 10
ENTITY_HEIGHT = 22
ENTITY_XOFFSET = 5
ENTITY_YOFFSET = 11

ENTTY_PRIORITY = 2

STAND_FRAME_DELAY = 190
BLINK_FRAME_DELAY = 3

WALK_FRAME_DELAY = 6
SLIDE_FRAME_DELAY = 2



.segment ENTITY_STATE_BANK

	; PlayerEntityStruct
LABEL	Entity_Player
	.word	Entity_Player_End - Entity_Player	; size
	.addr	Player__FunctionsTable			; functionsTable
	.byte	0, 0, 0					; xPos
	.byte	0, 0, 0					; yPos
	.word	ENTITY_WIDTH				; size_width
	.word	ENTITY_HEIGHT				; size_height
	.word	ENTITY_XOFFSET				; size_xOffset
	.word	ENTITY_YOFFSET				; size_yOffset
	.addr	0					; metaSpriteFrame
	.word	0					; metaSpriteCharAttr
	.addr	AnimationTable				; animationTable
	.addr	0					; animationPC
	.word	0					; tileVramLocation
	.byte	Player_AnimationId::WALK_RIGHT		; animationId
	.byte	0					; animationFrameDelay
	.word	0					; xVecl
	.word	0					; yVecl
	.addr	0					; standingTile
	.addr	0					; currentTileProperty
	.word	$FFFF					; facingLeftOnZero
Entity_Player_End:


.segment ANIMATION_TABLE_BANK

AnimationTable:
	.byte	.bankbyte(_Tiles)
	.addr	Tiles_HeadRow
	.byte	AnimationDmaTransferType::TWO_ROWS_LEFT
	.word	Tiles_RowSize
	.addr	Palette

	.addr	Animation_StandLeft
	.addr	Animation_StandRight
	.addr	Animation_WalkLeft
	.addr	Animation_WalkRight
	.addr	Animation_SlideLeft
	.addr	Animation_SlideRight
	.addr	Animation_JumpLeft
	.addr	Animation_JumpRight
	.addr	Animation_FallLeft
	.addr	Animation_FallRight
	.addr	Animation_Dead



.segment ANIMATION_PALETTE_BANK

Palette:
	.incbin "player.clr", 2, 15 * 2


.segment "BANK2"

_Tiles:
	.incbin "player.4bpp"

Tiles_RowSize   = 8 * 32
Tiles_HeadRow   = _Tiles
Tiles_WalkRow1  = _Tiles + 8 * 2 * 32 * 1
Tiles_WalkRow2  = _Tiles + 8 * 2 * 32 * 2
Tiles_ActionRow = _Tiles + 8 * 2 * 32 * 3


.segment ANIMATION_BANK

Animation_StandLeft:
	.byte	AnimationBytecode::LOAD_TILES16_RIGHT_HALF
		.addr	Tiles_WalkRow1
_Animation_StandLeft_Loop:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_StandLeft
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	STAND_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_BlinkLeft
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	BLINK_FRAME_DELAY
	.byte	AnimationBytecode::GOTO
		.addr	_Animation_StandLeft_Loop


Animation_StandRight:
	.byte	AnimationBytecode::LOAD_TILES16_RIGHT_HALF
		.addr	Tiles_WalkRow1
_Animation_StandRight_Loop:
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_StandRight
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	STAND_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_BlinkRight
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	BLINK_FRAME_DELAY
	.byte	AnimationBytecode::GOTO
		.addr	_Animation_StandRight_Loop



Animation_WalkLeft:
	.byte	AnimationBytecode::LOAD_TILES16_RIGHT_HALF
		.addr	Tiles_WalkRow1

	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkLeft0
	.byte	AnimationBytecode::WAIT_FRAMES_XVECL2
		.byte	WALK_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkLeft1
	.byte	AnimationBytecode::WAIT_FRAMES_XVECL2
		.byte	WALK_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkLeft2
	.byte	AnimationBytecode::WAIT_FRAMES_XVECL2
		.byte	WALK_FRAME_DELAY

	.byte	AnimationBytecode::LOAD_TILES16_RIGHT_HALF
		.addr	Tiles_WalkRow2

	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkLeft3
	.byte	AnimationBytecode::WAIT_FRAMES_XVECL2
		.byte	WALK_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkLeft4
	.byte	AnimationBytecode::WAIT_FRAMES_XVECL2
		.byte	WALK_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkLeft5
	.byte	AnimationBytecode::WAIT_FRAMES_XVECL2
		.byte	WALK_FRAME_DELAY

	.byte	AnimationBytecode::GOTO
		.addr	Animation_WalkLeft


Animation_WalkRight:
	.byte	AnimationBytecode::LOAD_TILES16_RIGHT_HALF
		.addr	Tiles_WalkRow1

	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkRight0
	.byte	AnimationBytecode::WAIT_FRAMES_XVECL2
		.byte	WALK_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkRight1
	.byte	AnimationBytecode::WAIT_FRAMES_XVECL2
		.byte	WALK_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkRight2
	.byte	AnimationBytecode::WAIT_FRAMES_XVECL2
		.byte	WALK_FRAME_DELAY

	.byte	AnimationBytecode::LOAD_TILES16_RIGHT_HALF
		.addr	Tiles_WalkRow2

	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkRight3
	.byte	AnimationBytecode::WAIT_FRAMES_XVECL2
		.byte	WALK_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkRight4
	.byte	AnimationBytecode::WAIT_FRAMES_XVECL2
		.byte	WALK_FRAME_DELAY
	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_WalkRight5
	.byte	AnimationBytecode::WAIT_FRAMES_XVECL2
		.byte	WALK_FRAME_DELAY

	.byte	AnimationBytecode::GOTO
		.addr	Animation_WalkRight


Animation_SlideLeft:
	.byte	AnimationBytecode::LOAD_TILES16_RIGHT_HALF
		.addr	Tiles_WalkRow1

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

	.byte	AnimationBytecode::LOAD_TILES16_RIGHT_HALF
		.addr	Tiles_WalkRow2

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
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	SLIDE_FRAME_DELAY

	.byte	AnimationBytecode::GOTO
		.addr	Animation_SlideLeft


Animation_SlideRight:
	.byte	AnimationBytecode::LOAD_TILES16_RIGHT_HALF
		.addr	Tiles_WalkRow1

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

	.byte	AnimationBytecode::LOAD_TILES16_RIGHT_HALF
		.addr	Tiles_WalkRow2

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
	.byte	AnimationBytecode::WAIT_FRAMES
		.byte	SLIDE_FRAME_DELAY

	.byte	AnimationBytecode::GOTO
		.addr	Animation_SlideRight



Animation_JumpLeft:
	.byte	AnimationBytecode::LOAD_TILES16_RIGHT_HALF
		.addr	Tiles_ActionRow

	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_JumpLeft
	.byte	AnimationBytecode::STOP


Animation_JumpRight:
	.byte	AnimationBytecode::LOAD_TILES16_RIGHT_HALF
		.addr	Tiles_ActionRow

	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_JumpRight
	.byte	AnimationBytecode::STOP



Animation_FallLeft:
	.byte	AnimationBytecode::LOAD_TILES16_RIGHT_HALF
		.addr	Tiles_ActionRow

	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_FallLeft
	.byte	AnimationBytecode::STOP


Animation_FallRight:
	.byte	AnimationBytecode::LOAD_TILES16_RIGHT_HALF
		.addr	Tiles_ActionRow

	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_FallRight
	.byte	AnimationBytecode::STOP


Animation_Dead:
	.byte	AnimationBytecode::LOAD_TILES16_RIGHT_HALF
		.addr	Tiles_ActionRow

	.byte	AnimationBytecode::SET_FRAME
		.addr	Frame_Dead
	.byte	AnimationBytecode::STOP


.segment METASPRITE_FRAME_BANK

; Left - heads
; Right - Walk1
Frame_StandLeft:
	.byte	3
		MetaSprite	 -8, -12,  1, SMALL, ENTTY_PRIORITY, MS_HFLIP
		MetaSprite	  0, -12,  0, SMALL, ENTTY_PRIORITY, MS_HFLIP
		MetaSprite	 -8,  -4,  8, BIG,   ENTTY_PRIORITY, MS_HFLIP

Frame_StandRight:
	.byte	3
		MetaSprite	 -8, -12,  0, SMALL, ENTTY_PRIORITY
		MetaSprite	  0, -12,  1, SMALL, ENTTY_PRIORITY
		MetaSprite	 -8,  -4,  8, BIG,   ENTTY_PRIORITY


; Left - heads
; Right - Walk1
Frame_BlinkLeft:
	.byte	3
		MetaSprite	 -8, -12,  7, SMALL, ENTTY_PRIORITY, MS_HFLIP
		MetaSprite	  0, -12,  6, SMALL, ENTTY_PRIORITY, MS_HFLIP
		MetaSprite	 -8,  -4,  8, BIG,   ENTTY_PRIORITY, MS_HFLIP

Frame_BlinkRight:
	.byte	3
		MetaSprite	 -8, -12,  6, SMALL, ENTTY_PRIORITY
		MetaSprite	  0, -12,  7, SMALL, ENTTY_PRIORITY
		MetaSprite	 -8,  -4,  8, BIG,   ENTTY_PRIORITY


; Left - heads
; Right - Walk1
Frame_WalkLeft0:
	.byte	3
		MetaSprite	 -8, -12,  3, SMALL, ENTTY_PRIORITY, MS_HFLIP
		MetaSprite	  0, -12,  2, SMALL, ENTTY_PRIORITY, MS_HFLIP
		MetaSprite	 -8,  -4, 10, BIG,   ENTTY_PRIORITY, MS_HFLIP

Frame_WalkRight0:
	.byte	3
		MetaSprite	 -8, -12,  2, SMALL, ENTTY_PRIORITY
		MetaSprite	  0, -12,  3, SMALL, ENTTY_PRIORITY
		MetaSprite	 -8,  -4, 10, BIG,   ENTTY_PRIORITY


; Left - heads
; Right - Walk1
Frame_WalkLeft1:
	.byte	3
		MetaSprite	 -8, -12,  5, SMALL, ENTTY_PRIORITY, MS_HFLIP
		MetaSprite	  0, -12,  4, SMALL, ENTTY_PRIORITY, MS_HFLIP
		MetaSprite	 -8,  -4, 12, BIG,   ENTTY_PRIORITY, MS_HFLIP

Frame_WalkRight1:
	.byte	3
		MetaSprite	 -8, -12,  4, SMALL, ENTTY_PRIORITY
		MetaSprite	  0, -12,  5, SMALL, ENTTY_PRIORITY
		MetaSprite	 -8,  -4, 12, BIG,   ENTTY_PRIORITY


; Left - heads
; Right - Walk2
Frame_WalkLeft2:
	.byte	3
		MetaSprite	 -8, -12,  3, SMALL, ENTTY_PRIORITY, MS_HFLIP
		MetaSprite	  0, -12,  2, SMALL, ENTTY_PRIORITY, MS_HFLIP
		MetaSprite	 -8,  -4, 14, BIG,   ENTTY_PRIORITY, MS_HFLIP

Frame_WalkRight2:
	.byte	3
		MetaSprite	 -8, -12,  2, SMALL, ENTTY_PRIORITY
		MetaSprite	  0, -12,  3, SMALL, ENTTY_PRIORITY
		MetaSprite	 -8,  -4, 14, BIG,   ENTTY_PRIORITY


; Left - heads
; Right - Walk2
Frame_WalkLeft3:
	.byte	3
		MetaSprite	 -8, -12,  3, SMALL, ENTTY_PRIORITY, MS_HFLIP
		MetaSprite	  0, -12,  2, SMALL, ENTTY_PRIORITY, MS_HFLIP
		MetaSprite	 -8,  -4,  8, BIG,   ENTTY_PRIORITY, MS_HFLIP

Frame_WalkRight3:
	.byte	3
		MetaSprite	 -8, -12,  2, SMALL, ENTTY_PRIORITY
		MetaSprite	  0, -12,  3, SMALL, ENTTY_PRIORITY
		MetaSprite	 -8,  -4,  8, BIG,   ENTTY_PRIORITY


; Left - heads
; Right - Walk2
Frame_WalkLeft4:
	.byte	3
		MetaSprite	 -8, -12,  5, SMALL, ENTTY_PRIORITY, MS_HFLIP
		MetaSprite	  0, -12,  4, SMALL, ENTTY_PRIORITY, MS_HFLIP
		MetaSprite	 -8,  -4, 10, BIG,   ENTTY_PRIORITY, MS_HFLIP

Frame_WalkRight4:
	.byte	3
		MetaSprite	 -8, -12,  4, SMALL, ENTTY_PRIORITY
		MetaSprite	  0, -12,  5, SMALL, ENTTY_PRIORITY
		MetaSprite	 -8,  -4, 10, BIG,   ENTTY_PRIORITY


; Left - heads
; Right - Walk2
Frame_WalkLeft5:
	.byte	3
		MetaSprite	 -8, -12,  3, SMALL, ENTTY_PRIORITY, MS_HFLIP
		MetaSprite	  0, -12,  2, SMALL, ENTTY_PRIORITY, MS_HFLIP
		MetaSprite	 -8,  -4, 12, BIG,   ENTTY_PRIORITY, MS_HFLIP

Frame_WalkRight5:
	.byte	3
		MetaSprite	 -8, -12,  2, SMALL, ENTTY_PRIORITY
		MetaSprite	  0, -12,  3, SMALL, ENTTY_PRIORITY
		MetaSprite	 -8,  -4, 12, BIG,   ENTTY_PRIORITY

; Left - heads
; Right - action
Frame_JumpLeft:
	.byte	3
		MetaSprite	 -8, -12, 17, SMALL, ENTTY_PRIORITY, MS_HFLIP
		MetaSprite	  0, -12, 16, SMALL, ENTTY_PRIORITY, MS_HFLIP
		MetaSprite	 -8,  -4,  8, BIG,   ENTTY_PRIORITY, MS_HFLIP

Frame_JumpRight:
	.byte	3
		MetaSprite	 -8, -12, 16, SMALL, ENTTY_PRIORITY
		MetaSprite	  0, -12, 17, SMALL, ENTTY_PRIORITY
		MetaSprite	 -8,  -4,  8, BIG,   ENTTY_PRIORITY


; Left - heads
; Right - action
Frame_FallLeft:
	.byte	3
		MetaSprite	 -8, -12, 19, SMALL, ENTTY_PRIORITY, MS_HFLIP
		MetaSprite	  0, -12, 18, SMALL, ENTTY_PRIORITY, MS_HFLIP
		MetaSprite	 -8,  -4, 10, BIG,   ENTTY_PRIORITY, MS_HFLIP

Frame_FallRight:
	.byte	3
		MetaSprite	 -8, -12, 18, SMALL, ENTTY_PRIORITY
		MetaSprite	  0, -12, 19, SMALL, ENTTY_PRIORITY
		MetaSprite	 -8,  -4, 10, BIG,   ENTTY_PRIORITY


; Left - heads
; Right - action
Frame_Dead:
	.byte	3
		MetaSprite	 -8, -12, 20, SMALL, ENTTY_PRIORITY
		MetaSprite	  0, -12, 21, SMALL, ENTTY_PRIORITY
		MetaSprite	 -8,  -4, 12, BIG,   ENTTY_PRIORITY
.endproc

; vim: ft=asm:

