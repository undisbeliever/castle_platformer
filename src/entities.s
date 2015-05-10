
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

;; ::SHOULDO segment called SHADOW_OBJECTS - starts at $1000
;; ::: so I don't loose lots of space by the linker::
.segment "SHADOW"
	.align	$100	; optimize DP access

	BYTE	player, ENTITY_MALLOC

	;; Object pool of npcs.
	;; Must be in shadow, accessed via direct page.
	BYTE	npcPool, N_ACTIVE_NPCS * ENTITY_MALLOC

	;; Object pool of player projectiles
	;; Must be in shadow, accessed via direct page.
	BYTE	projectilePool, N_PROJECTILES * ENTITY_MALLOC

	WORD	parameter


.segment "WRAM7E"
	;; First npc in the active linked list.
	ADDR	firstActiveNpc
	;; First npc in the free linked list
	ADDR	firstFreeNpc

	;; First prjectile in the active linked list.
	ADDR	firstActiveProjectile
	;; First prjectile in the free linked list
	ADDR	firstFreeProjectile

	;; Stores projectile variable in CheckNpcProjectileCollisions.
	ADDR	projectileTmp

	;; The prvious item in the linked list.
	;; Used by the list to free memory in a mark and sweek style list deletion.
	WORD	previousEntity

	WORD	tmp


.code


.macro _Init_BuildList firstActive, firstFree, pool, nEntities, entitySize
	; firstActive = NULL
	; firstFree = projectiles
	; for dp in pool to pool[nEntities - 2]
	;	dp->functionsTable = NULL
	;	dp->nextEntity = &dp + NPC_ENTITY_MALLOC
	; pool[nEntities - 1] = NULL

	STZ	firstActive
	LDA	#pool
	STA	firstFree
	REPEAT
		TCD

		STZ	z:EntityStruct::functionsTable
		ADD	#entitySize
		STA	z:EntityStruct::nextEntity

		CMP	#pool + (nEntities - 1) * entitySize
	UNTIL_GE

	; Last one terminates the list
	STZ	pool + (nEntities - 1) * entitySize
.endmacro


ROUTINE Init
	PHP
	PHD
	REP	#$30
.A16
.I16

	_Init_BuildList firstActiveNpc, firstFreeNpc, npcPool, N_ACTIVE_NPCS, ENTITY_MALLOC
	_Init_BuildList firstActiveProjectile, firstFreeProjectile, projectilePool, N_PROJECTILES, ENTITY_MALLOC

	PLD
	PLP
	RTS



.A16
.I16
ROUTINE NewPlayer
	PHD
	PHY
	PHX

	TAX
	LDA	f:EntityStateBank << 16, X
	LDY	#player + 2
	INX
	INX

	MVN	$7E, EntityStateBank

	LDA	#player
	TCD

	PLA
	STA	z:EntityStruct::xPos + 1
	PLA
	STA	z:EntityStruct::yPos + 1

	LDX	z:EntityStruct::functionsTable

	LDA	parameter
	JSR	(PlayerEntityFunctionsTable::Init, X)

	PLD
	RTS



.A16
.I16
ROUTINE Process
	LDA	#player
	TCD

	LDX	z:EntityStruct::functionsTable
	JSR	(PlayerEntityFunctionsTable::Process, X)

	RTS


.A8
.I16
ROUTINE Render
	JSR	MetaSprite__InitLoop

	REP	#$30
.A16
.I16
	LDA	#player
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
.A16
.I16

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



.segment ENTITY_STATE_BANK
	EntityStateBank = .bankbyte(*)

ENDMODULE

