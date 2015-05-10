
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
SCREEN_LEFT_RIGHT_SPACING = 95
SCREEN_UP_DOWN_SPACING = 65

; ::TODO move somewhere else

ENTITY_WIDTH = 16
ENTITY_HEIGHT = 24
ENTITY_XOFFSET = 8
ENTITY_YOFFSET = 16

.define PES PlayerEntityStruct


MODULE Player
	SAME_VARIABLE entity, Entities__player

.rodata
LABEL	FunctionsTable
	.addr	.loword(Init)
	.addr	.loword(Process)


; dp = entity
.A8
.I16
ROUTINE Init
	; ::TODO dynamicaly load player tiles and palette::
	SEP	#$20
.A8
	PHB
	PHK
	PLB
	TransferToVramLocation	ExampleObjectTiles,	GAMELOOP_OAM_TILES
	TransferToCgramLocation	ExampleObjectPalette,	128

	REP	#$20
.A16
	PLB
	RTS


; DP = entity
.A16
.I16
ROUTINE Process
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
	LDA	z:PES::xPos + 1
	SUB	MetaTiles1x16__xPos
	CMP	#256 - SCREEN_LEFT_RIGHT_SPACING
	IF_SGE
		LDA	z:PES::xPos + 1
		SUB	#256 - SCREEN_LEFT_RIGHT_SPACING
		CMP	MetaTiles1x16__maxXPos
		IF_GE
			LDA	MetaTiles1x16__maxXPos
		ENDIF
		STA	MetaTiles1x16__xPos
	ELSE
		CMP	#SCREEN_LEFT_RIGHT_SPACING
		IF_SLT
			LDA	z:PES::xPos + 1
			SUB	#SCREEN_LEFT_RIGHT_SPACING
			IF_MINUS
				LDA	#0
			ENDIF
			STA	MetaTiles1x16__xPos
		ENDIF
	ENDIF

	LDA	z:PES::yPos + 1
	SUB	MetaTiles1x16__yPos
	CMP	#224 - SCREEN_UP_DOWN_SPACING
	IF_SGE
		LDA	z:PES::yPos + 1
		SUB	#224 - SCREEN_UP_DOWN_SPACING
		CMP	MetaTiles1x16__maxYPos
		IF_GE
			LDA	MetaTiles1x16__maxYPos
		ENDIF
		STA	MetaTiles1x16__yPos
	ELSE
		CMP	#SCREEN_UP_DOWN_SPACING
		IF_SLT
			LDA	z:PES::yPos + 1
			SUB	#SCREEN_UP_DOWN_SPACING
			IF_MINUS
				LDA	#0
			ENDIF
			STA	MetaTiles1x16__yPos
		ENDIF
	ENDIF

	RTS


.segment ENTITY_STATE_BANK

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
	.word	0				; xVecl
	.word	0				; yVecl
	.addr	0				; standingTile
	.addr	0				; currentTileProperty
InitState_End:


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

