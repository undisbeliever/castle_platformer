
.include "player.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "maploader.h"
.include "physics.h"
.include "controller.h"

.include "routines/block.h"
.include "routines/metasprite.h"
.include "routines/metatiles/metatiles-1x16.h"

; ::TODO move somewhere else
GRAVITY = 41			; Acceleration due to gravity in 1/256 pixels per frame per frame

SCREEN_LEFT_RIGHT_SPACING = 85
SCREEN_UP_DOWN_SPACING = 56

MODULE Player

.segment "SHADOW"
	STRUCT	player, EntityStruct
.code

.A8
.I16
ROUTINE Init
	STZ	player + EntityStruct::xPos
	LDX	#825
	STX	player + EntityStruct::xPos + 1

	STZ	player + EntityStruct::yPos
	LDY	#200
	STY	player + EntityStruct::yPos + 1

	LDX	#0
	STX	player + EntityStruct::xVecl
	STX	player + EntityStruct::yVecl
	STX	player + EntityStruct::standingTile

	LDX	#.loword(ExampleMetaSpriteFrame)
	STX	player + EntityStruct::metaSpriteFrame
	LDX	#0
	STX	player + EntityStruct::metaSpriteCharAttr

	; ::TODO dynamicaly load player tiles and palette::
	TransferToVramLocation	ExampleObjectTiles,	METATILES_OAM_TILES
	TransferToCgramLocation	ExampleObjectPalette,	128

	RTS


.A8
.I16
ROUTINE Update
	PHD

	REP	#$20
.A16

	LDA	#player
	TCD

	LDA	Controller__current
	IF_BIT	#JOY_LEFT
		LDA	z:EntityStruct::xVecl
		SUB	#80
		CMP	#.loword(-512 - 1)
		IF_SLT
			LDA	#.loword(-512)
		ENDIF
		STA	z:EntityStruct::xVecl
	ELSE_BIT #JOY_RIGHT
		LDA	z:EntityStruct::xVecl
		ADD	#80
		CMP	#512 + 1
		IF_SGE
			LDA	#512
		ENDIF
		STA	z:EntityStruct::xVecl
	ENDIF

	LDA	Controller__current
	IF_BIT	#JOY_B
		LDX	z:EntityStruct::standingTile
		IF_NOT_ZERO
			LDA	#.loword(-1024)
			STA	z:EntityStruct::yVecl
		ENDIF
	ENDIF

	JSR	Physics__ProcessEntity

	; Move screen with player
	; ::MAYDO integrate with physics movements::

	LDA	z:EntityStruct::xPos + 1
	SUB	MetaTiles1x16__xPos
	CMP	#256 - SCREEN_LEFT_RIGHT_SPACING
	IF_SGE
		LDA	z:EntityStruct::xPos + 1
		SUB	#256 - SCREEN_LEFT_RIGHT_SPACING
		CMP	MetaTiles1x16__maxXPos
		IF_GE
			LDA	MetaTiles1x16__maxXPos
		ENDIF
		STA	MetaTiles1x16__xPos
	ELSE
		CMP	#SCREEN_LEFT_RIGHT_SPACING
		IF_SLT
			LDA	z:EntityStruct::xPos + 1
			SUB	#SCREEN_LEFT_RIGHT_SPACING
			IF_MINUS
				LDA	#0
			ENDIF
			STA	MetaTiles1x16__xPos
		ENDIF
	ENDIF

	LDA	z:EntityStruct::yPos + 1
	SUB	MetaTiles1x16__yPos
	CMP	#224 - SCREEN_UP_DOWN_SPACING
	IF_SGE
		LDA	z:EntityStruct::yPos + 1
		SUB	#224 - SCREEN_UP_DOWN_SPACING
		CMP	MetaTiles1x16__maxYPos
		IF_GE
			LDA	MetaTiles1x16__maxYPos
		ENDIF
		STA	MetaTiles1x16__yPos
	ELSE
		CMP	#SCREEN_UP_DOWN_SPACING
		IF_SLT
			LDA	z:EntityStruct::yPos + 1
			SUB	#SCREEN_UP_DOWN_SPACING
			IF_MINUS
				LDA	#0
			ENDIF
			STA	MetaTiles1x16__yPos
		ENDIF
	ENDIF

	SEP	#$20
.A8

	PLD
	RTS



.A8
.I16
ROUTINE Render
	REP	#$30
.A16
.I16

	LDA	player + EntityStruct::xPos + 1
	SUB	MetaTiles1x16__xPos
	STA	MetaSprite__xPos

	LDA	player + EntityStruct::yPos + 1
	SUB	MetaTiles1x16__yPos
	STA	MetaSprite__yPos

	; ::SHOULDDO use DB = MetaSpriteLayoutBank, saves (n_entities + 4*obj - 7) cycles::
	; ::: Will require MetaSpriteLayoutBank & $7F <= $3F::
	LDX	player + EntityStruct::metaSpriteFrame
	LDY	player + EntityStruct::metaSpriteCharAttr

	SEP	#$20
.A8
	JMP	MetaSprite__ProcessMetaSprite_Y



.segment "BANK1"

;; TEST example data::

.export MetaSpriteLayoutBank = .bankbyte(*)

ExampleMetaSpriteFrame:
	.byte	2
	.byte	.lobyte(-8)
	.byte	.lobyte(-8)
	.word	$0000
	.byte	$FF
	.byte	.lobyte(-4)
	.byte	.lobyte(-16)
	.word	$0000
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

