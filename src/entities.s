
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

	WORD	playerTmp
	WORD	npcTmp

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
	DEC
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



; INPUT: X = xpos, Y = ypos, A = address in InitBank of data
;	parameter = parameter to pass to init function
; REGISTERS: 16 bit A, 16 bit Index, DB=$7E
; OUT: A/Y = entity created address. NULL if no entity created.
;	z flag clear if entity created, otherwise set.
; PARAM: firstFiree/firstActive = free/active linked list head.
;	InitRoutine the routine in the functions table to call
.macro _NewEntity firstFree, firstActive, InitRoutine
	; tmp = A
	; if firstFree != 0
	;	dp = firstFree
	;
	;	next = z:EntityStruct::nextEntity
	;	xPos = X
	;	yPos = Y
	;
	;	size = EntityStateBank[tmp]
	;	MemCopy(EntityStateBank[tmp] + 2, dp + 2, size - 3)
	;
	;	dp->xPos = xPos
	;	dp->yPos = yPos
	;
	;	firstFree = dp->next
	;	dp->nextEntity = firstActive
	;	firstActive = dp
	;
	;	dp->InitRoutine(parameter)

	STA	tmp

	LDA	firstFree
	IF_NOT_ZERO
		PHD
		TCD

		PHY
		PHX

		TAY

		LDX	tmp
		LDA	f:EntityStateBank << 16, X

		; 14 cycles saved not loading 2 bytes
		; 5 cycles saved not overwriting nextEntity
		SUB	#3
		INX
		INX
		INY
		INY

		MVN	$7E, EntityStateBank

		PLA
		STA	z:EntityStruct::xPos + 1
		PLA
		STA	z:EntityStruct::yPos + 1

		LDA	z:EntityStruct::nextEntity
		STA	firstFree

		LDA	firstActive
		STA	z:EntityStruct::nextEntity

		TDC
		STA	firstActive

		LDA	parameter
		LDX	z:EntityStruct::functionsTable
		JSR	(InitRoutine, X)

		TDC
		PLD

		TAY
		RTS
	ENDIF

	LDY	#0
	RTS
.endmacro


.A16
.I16
ROUTINE NewNpc
	_NewEntity firstFreeNpc, firstActiveNpc, NpcEntityFunctionsTable::Init


.A16
.I16
ROUTINE NewProjectile
	_NewEntity firstFreeProjectile, firstActiveProjectile, ProjectileEntityFunctionsTable::Init



;; Preforms a bounding box collision between the current NPC (dp) and the player.
;;
;; If there is a collision, it will call the Entity's Player Collision routine.
;;
;; This macro ignores the fractional part of xPos/yPos
;;
;; REQUIRES: 16 bit A, 16 bit Index
;; PARAM:
;;	player: the address of the player's EntityStruct.
;;	EntityCollisionRoutine: the routine in the Entity's finction table to call if there is a collision
;; INPUT:
;;	DP: address of npc
;; OUTPUT: branches to _NpcDead if NPC is dead.
.macro Process_CheckNpcPlayerCollision
	; Research
	; --------
	; The following is the fastest I can think of.
	; for simple 1 dimensional ideas (16 bit A, DP.l != 0):
	;	a.left in range(b.left, b.left + b.width) | b.left in range(a.left, a.left + a.width) = 36 cycles
	;	abs(a.left - b.left) < (a.width + b.width) / 2 = 43 cycles
	;	a.left < b.left ? (a.left + a.width >= b.left) : (b.left + b.width >= a.left) = 12-33 cyles
	;	a.left < b.left ? (a.left + a.width >= b.left) : (a.left - b.width < b.left) = 25-26 cycles


	;	playerLeft = player.xPos - player.size_xOffset
	;	npcLeft = npc->xPos - npc->size_xOffset
	;
	; 	if npcLeft < playerLeft
	;		if npcLeft + npc->size_width < playerLeft
	;			goto NoCollision
	; 	else
	;		if npcLeft - player.size_width >= playerLeft
	;			goto NoCollision
	;
	;	playerTop = player.yPos - player.size_yOffset
	;	npcTop = npc->yPos - npc->size_yOffset
	;
	; 	if npcTop < playerTop
	;		if npcTop + npc->size_height < playerTop
	;			goto NoCollision
	; 	else
	;		if npcLeft player.size_height >= playerTop
	;			goto NoCollision
	;
	; 	CollisionRoutine(npc)
	;	npc->functionsTable->CollisionPlayer(npc)
	;

	;; ::TODO assert .asize = 16::
	.A16
	.I16

	.local NoNpcPlayerCollision
	.local playerLeft, playerTop, npcLeft, npcTop

	playerLeft = playerTmp
	playerTop = playerTmp
	npcLeft = npcTmp
	npcTop = npcTmp

	LDA	a:player + EntityStruct::xPos + 1
	SUB	a:player + EntityStruct::size_xOffset
	STA	playerLeft

	LDA	z:EntityStruct::xPos + 1
	SUB	z:EntityStruct::size_xOffset
	STA	npcLeft

	CMP	playerLeft
	IF_LT
		; carry clear, A = npcLeft
		ADC	z:EntityStruct::size_width
		CMP	playerLeft
		BSLT	NoNpcPlayerCollision
	ELSE
		; carry set, A = npcLeft
		SBC	a:player + EntityStruct::size_width
		CMP	playerLeft
		BSGE	NoNpcPlayerCollision
	ENDIF

	LDA	a:player + EntityStruct::yPos + 1
	SUB	a:player + EntityStruct::size_yOffset
	STA	playerTop

	LDA	z:EntityStruct::yPos + 1
	SUB	z:EntityStruct::size_yOffset
	STA	npcTop

	CMP	playerTop
	IF_LT
		; carry clear, A = npcTop
		ADC	z:EntityStruct::size_height
		CMP	playerTop
		BSLT	NoNpcPlayerCollision
	ELSE
		; carry set, A = npcTop
		SBC	a:player + EntityStruct::size_height
		CMP	playerTop
		BSGE	NoNpcPlayerCollision
	ENDIF

	LDX	z:EntityStruct::functionsTable
	JSR	(NpcEntityFunctionsTable::CollisionPlayer, X)
	BCC	_NpcDead

NoNpcPlayerCollision:
.endmacro




.A16
.I16
ROUTINE Process
	LDA	#player
	TCD

	LDX	z:EntityStruct::functionsTable
	JSR	(PlayerEntityFunctionsTable::Process, X)


	; Projectile Loop
	; ---------------
	STZ	previousEntity

	LDA	firstActiveProjectile
	IF_NOT_ZERO
		REPEAT
			TCD

			LDX	z:EntityStruct::functionsTable
			JSR	(ProjectileEntityFunctionsTable::Process, X)
			IF_C_CLEAR
_ProjectileDead:		; Projectile is dead.
				; Calls Projectile->Destructor
				; Remove the entity from the list
				; Move memory into free list.
				; Resume Projectile loop if there are more entities to process.

				LDA	z:EntityStruct::nextEntity
				TAY

				LDX	previousEntity
				IF_ZERO
					STA	firstActiveProjectile
				ELSE
					STA	a:EntityStruct::nextEntity, X
				ENDIF

				LDA	firstFreeProjectile
				STA	z:EntityStruct::nextEntity
				TDC
				STA	firstFreeProjectile

				TYA
			ELSE

				; projectile still alive
				TDC
				STA	previousEntity
				LDA	z:EntityStruct::nextEntity
			ENDIF
		UNTIL_ZERO
	ENDIF


	; NPC Loop
	; --------
	STZ	previousEntity

	LDA	firstActiveNpc
	IF_ZERO
		RTS
	ENDIF

	REPEAT
		TCD

		LDX	z:EntityStruct::functionsTable
		JSR	(NpcEntityFunctionsTable::Process, X)
		IF_C_CLEAR
_NpcDead:		; NPC is dead.
			; Calls NPC->Destructor
			; Remove the entity from the list
			; Move memory into free list.
			; Resume NPC loop if there are more entities to process.

			LDA	z:EntityStruct::nextEntity
			TAY

			LDX	previousEntity
			IF_ZERO
				STA	firstActiveNpc
			ELSE
				STA	a:EntityStruct::nextEntity, X
			ENDIF

			LDA	firstFreeNpc
			STA	z:EntityStruct::nextEntity
			TDC
			STA	firstFreeNpc

			TYA
			BNE	CONTINUE_LABEL

			; branch is too far
			BRA	BREAK_LABEL
		ENDIF

		Process_CheckNpcPlayerCollision

		; ::TODO projectile collision tests::

		TDC
		STA	previousEntity
		LDA	z:EntityStruct::nextEntity
	UNTIL_ZERO

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

	LDX	z:EntityStruct::functionsTable
	IF_NOT_ZERO
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
	.A8
		JSR	MetaSprite__ProcessMetaSprite_Y

		REP	#$30
	ENDIF
.A16
.I16

	LDA	firstActiveNpc
	IF_NOT_ZERO
		JSR	RenderEntityLinkedList
	ENDIF

	LDA	firstActiveProjectile
	IF_NOT_ZERO
		JSR	RenderEntityLinkedList
	ENDIF

	SEP	#$20
.A8
	JMP	MetaSprite__FinalizeLoop



;; Render Entity List using metasprites
;; A = start of entity list
;; START REGISTERS: 16 bit A, 16 bit Index, DB access registers
;; END REGISTERS: 8 bit A, 16 bit Index, DB unchanged
.A16
.I16
ROUTINE RenderEntityLinkedList
	REPEAT
		TCD

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
.A8
		JSR	MetaSprite__ProcessMetaSprite_Y

		REP	#$30
.A16
.I16
		LDA	z:EntityStruct::nextEntity
	UNTIL_ZERO
	RTS



.segment ENTITY_STATE_BANK
	EntityStateBank = .bankbyte(*)

ENDMODULE

