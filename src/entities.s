
.include "entities.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "entity.h"
.include "entities/player.h"

.include "routines/metasprite.h"
.include "routines/metatiles/metatiles-1x16.h"

MODULE Entities


.A8
.I16
ROUTINE Render
	JSR	MetaSprite__InitLoop

	REP	#$30
.A16
	LDA	#.loword(Player__entity)
	TCD
	JSR	RenderEntity
.A8

	JMP	MetaSprite__FinalizeLoop



;; Render Entity using metasprites
;; DP = entity
.A8
.I16
ROUTINE RenderEntity
	REP	#$30

	LDA	z:EntityStruct::xPos + 1
	SUB	MetaTiles1x16__xPos
	STA	MetaSprite__xPos

	LDA	z:EntityStruct::yPos + 1
	SUB	MetaTiles1x16__yPos
	STA	MetaSprite__yPos

	; ::SHOULDDO use DB = MetaSpriteLayoutBank, saves (n_entities + 4*obj - 7) cycles::
	; ::: Will require MetaSpriteLayoutBank & $7F <= $3F::
	LDX	z:EntityStruct::metaSpriteFrame
	LDY	z:EntityStruct::metaSpriteCharAttr

	SEP	#$20
	JMP	MetaSprite__ProcessMetaSprite_Y



ENDMODULE

