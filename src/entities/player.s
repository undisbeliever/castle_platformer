
.include "player.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "../entities.h"
.include "../entity-physics.h"
.include "../controller.h"
.include "../gameloop.h"

.include "routines/block.h"
.include "routines/metasprite.h"
.include "routines/metatiles/metatiles-1x16.h"

; ::TODO move somewhere else
GRAVITY = 41			; Acceleration due to gravity in 1/256 pixels per frame per frame

SCREEN_LEFT_RIGHT_SPACING = 95
SCREEN_UP_DOWN_SPACING = 65

; ::TODO move somewhere else

ENTITY_WIDTH = 16
ENTITY_HEIGHT = 24
ENTITY_XOFFSET = 8
ENTITY_YOFFSET = 16

.define PES PlayerEntityStruct


MODULE Player

.segment "SHADOW"
	STRUCT	entity, PlayerEntityStruct
.code

.A8
.I16
ROUTINE Init

	; ::TODO dynamic starting position::
	STZ	entity + PES::xPos
	LDX	#80
	STX	entity + PES::xPos + 1

	STZ	entity + PES::yPos
	LDY	#200
	STY	entity + PES::yPos + 1

	LDX	#0
	STX	entity + PES::xVecl
	STX	entity + PES::yVecl
	STX	entity + PES::standingTile

	LDX	#ENTITY_WIDTH
	STX	entity + PES::size_width
	LDX	#ENTITY_HEIGHT
	STX	entity + PES::size_height
	LDX	#ENTITY_XOFFSET
	STX	entity + PES::size_xOffset
	LDX	#ENTITY_YOFFSET
	STX	entity + PES::size_yOffset

	LDX	#.loword(ExampleMetaSpriteFrame)
	STX	entity + PES::metaSpriteFrame
	LDX	#0
	STX	entity + PES::metaSpriteCharAttr

	; ::TODO dynamicaly load player tiles and palette::
	TransferToVramLocation	ExampleObjectTiles,	GAMELOOP_OAM_TILES
	TransferToCgramLocation	ExampleObjectPalette,	128

	RTS


; DP = entity
.A16
.I16
ROUTINE Update
	LDA	Controller__current
	JSR	EntityPhysics__MoveEntityWithController

	JSR	EntityPhysics__EntityPhysicsWithCollisions

	; Player/tile interactions
	LDX	EntityPhysics__entityTouchTileFunctionPtr
	IF_NOT_ZERO
		JSR	(MetaTileFunctionsTable::PlayerTouch, X)
	ENDIF


	LDY	z:PES::standingTile
	IF_NOT_ZERO
		LDX	z:PES::currentTileProperty
		LDA	f:MetaTilePropertyBank << 16 + MetaTilePropertyStruct::functionsTable, X
		IF_NOT_ZERO
			TAX
			JMP	(MetaTileFunctionsTable::PlayerStand, X)
		ENDIF
	ENDIF

	; only here if there is no standing tile.

	RTS



.A16
.I16
ROUTINE	SetScreenPosition
	LDA	entity + PES::xPos + 1
	SUB	MetaTiles1x16__xPos
	CMP	#256 - SCREEN_LEFT_RIGHT_SPACING
	IF_SGE
		LDA	entity + PES::xPos + 1
		SUB	#256 - SCREEN_LEFT_RIGHT_SPACING
		CMP	MetaTiles1x16__maxXPos
		IF_GE
			LDA	MetaTiles1x16__maxXPos
		ENDIF
		STA	MetaTiles1x16__xPos
	ELSE
		CMP	#SCREEN_LEFT_RIGHT_SPACING
		IF_SLT
			LDA	entity + PES::xPos + 1
			SUB	#SCREEN_LEFT_RIGHT_SPACING
			IF_MINUS
				LDA	#0
			ENDIF
			STA	MetaTiles1x16__xPos
		ENDIF
	ENDIF

	LDA	entity + PES::yPos + 1
	SUB	MetaTiles1x16__yPos
	CMP	#224 - SCREEN_UP_DOWN_SPACING
	IF_SGE
		LDA	entity + PES::yPos + 1
		SUB	#224 - SCREEN_UP_DOWN_SPACING
		CMP	MetaTiles1x16__maxYPos
		IF_GE
			LDA	MetaTiles1x16__maxYPos
		ENDIF
		STA	MetaTiles1x16__yPos
	ELSE
		CMP	#SCREEN_UP_DOWN_SPACING
		IF_SLT
			LDA	entity + PES::yPos + 1
			SUB	#SCREEN_UP_DOWN_SPACING
			IF_MINUS
				LDA	#0
			ENDIF
			STA	MetaTiles1x16__yPos
		ENDIF
	ENDIF

	RTS



.segment "BANK1"

;; TEST example data::

.export MetaSpriteLayoutBank = .bankbyte(*)

ExampleMetaSpriteFrame:
	.byte	2
	.byte	.lobyte(-8)
	.byte	.lobyte(-8)
	.word	3 << OAM_CHARATTR_ORDER_SHIFT
	.byte	$FF
	.byte	.lobyte(-4)
	.byte	.lobyte(-16)
	.word	3 << OAM_CHARATTR_ORDER_SHIFT
	.byte	$00


ExampleObjectTiles:
	.repeat 32 * 32
		.byte	$FF
	.endrepeat
ExampleObjectTiles_End:

ExampleObjectPalette:
	.repeat	16
		.word	$FFFF
	.endrepeat
ExampleObjectPalette_End:

ENDMODULE

