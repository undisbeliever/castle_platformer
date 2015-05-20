
.include "entity-animation.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "gameloop.h"
.include "entity.h"

.include "routines/metasprite.h"

; last 2 rows ae free for other things
.define N_VRAM_SLOTS 15
.define N_PALETTE_SLOTS 7
.define N_VRAM_TRANSFERS 5

; each vram slot is 2 8x8 rows in size
VRAM_SLOT_SIZE = 16 * 2


; Ensure VBlank macros are used
.forceimport _EntityAnimation_VBlank__Called:zp



;; Table marking the data allocated to each palette and number of
;; entities using it.
;; Structure of arrays.
.struct PaletteSlotsTableStruct
	palettePtr	.res N_PALETTE_SLOTS * 2
	count		.res N_PALETTE_SLOTS * 2
.endstruct


MODULE EntityAnimation

.segment "SHADOW"
	;; Position of the cgram buffer.
	;; If 0 then no palettes are updated during VBlank
	WORD	cgramBufferPos
	;; Address of the data in `ANIMATION_PALETTES_BANK`
	ADDR	cgramBuffer_DataAddress, N_PALETTE_SLOTS
	;; Starting color number to store the palette to
	ADDR	cgramBuffer_StartingColor, N_PALETTE_SLOTS


	;; Position of the vram buffer
	;; If 0 then no tiles are updated during VBlank
	WORD	vramBufferPos

	;; Estimated number of bytes left to transfer this frame
	WORD	vramBufferBytesLeft

	;; Tuple - LSB data bank, MSB type of transfer
	WORD	vramBuffer_BankAndType, N_VRAM_TRANSFERS
	;; Address of the data
	WORD	vramBuffer_DataPtr, N_VRAM_TRANSFERS
	;; Size of the data
	WORD	vramBuffer_Size, N_VRAM_TRANSFERS
	;; VRAM word destination address
	WORD	vramBuffer_VramWordAddress, N_VRAM_TRANSFERS


.segment "WRAM7E"
_InitZero:
	;; Table marking the entities allocated to VRAM slot
	ADDR	entityInVramSlots, N_VRAM_SLOTS

	;; Table marking the palettes allocated.
	STRUCT	paletteSlotsTable, PaletteSlotsTableStruct
_InitZero_End:

	;; Used in searching through the palette
	ADDR	firstFreeSlot

	WORD	processSlotsPosition
	WORD	tmp

.code

.A16
.I16
ROUTINE Init
	STZ	cgramBufferPos
	STZ	vramBufferPos

	LDA	#ANIMATION_DMA_TRANSFER_BYTES
	STA	vramBufferBytesLeft

	.assert (_InitZero_End - _InitZero) .mod 2 = 0, error, "Must allocate an even number of bytes"

	LDX	#_InitZero_End - _InitZero - 2
	REPEAT
		STZ	_InitZero, X
		DEX
		DEX
	UNTIL_MINUS

	RTS



; ZP = EntityAnimationStruct
.A16
.I16
ROUTINE Activated
	; Find VRAM Slot
	; --------------

	LDX	#(N_VRAM_SLOTS - 1) * 2
	REPEAT
		LDA	entityInVramSlots, X
		IF_ZERO
			TDC
			STA	entityInVramSlots, X

			.assert VRAM_SLOT_SIZE * 16 = 512, error, "Incorrect code for value"
			TXA					; x is already a multiple of 2
			XBA					; 512
			ADD	#GAMELOOP_OAM_TILES
			STA	z:EntityAnimationStruct::tileVramWordAddress

			.assert VRAM_SLOT_SIZE = 32, error, "Incorrect code for value"
			TXA					; x is already a multiple of 2
			ASL					; 4
			ASL					; 8
			ASL					; 16
			ASL					; 32
			STA	z:EntityAnimationStruct::metaSpriteCharAttr

			BRA	_Activated_FoundEmptyVramSlot
		ENDIF

		DEX
		DEX
	UNTIL_MINUS

	; No Slots Available
	; ::TODO error handling::

	LDA	#GAMELOOP_OAM_TILES
	STA	z:EntityAnimationStruct::tileVramWordAddress
	STZ	z:EntityAnimationStruct::metaSpriteCharAttr


_Activated_FoundEmptyVramSlot:

	; Reset Animation PC
	; ------------------
	; entity->animationFrameDelay = $FF
	; entity->animationPC = AnimationTableBank[entity->animationTable].bytecodePtr[entity->animationId]
	.assert EntityAnimationStruct::animationId + 1 = EntityAnimationStruct::animationFrameDelay, error, "Bad Order"
	LDA	z:EntityAnimationStruct::animationId
	ORA	#$FF00
	STA	z:EntityAnimationStruct::animationId

	AND	#$00FF
	ASL
	ADD	z:EntityAnimationStruct::animationTable
	TAX
	LDA	f:AnimationTableBank << 16 + AnimationTableStruct::bytecodePtr, X
	STA	z:EntityAnimationStruct::animationPC

	; Load Palette
	; ------------
	LDX	z:EntityAnimationStruct::animationTable
	LDA	f:AnimationTableBank << 16 + AnimationTableStruct::palettePtr, X
	JSR	LoadPalette

	.assert * = InitialTileLoad, error, "Bad Flow"


;; Load entities initial tiles.
;; OUT: animationFrameDelay = 0 if successful
;;	animationFrameDelay = $FF if out of VBlank time.
.A16
.I16
ROUTINE InitialTileLoad
	LDX	z:EntityAnimationStruct::animationTable
	LDA	f:AnimationTableBank << 16 + AnimationTableStruct::tilesPtr, X
	BEQ	_Activated_NoLoadTiles

	TAY
	LDA	f:AnimationTableBank << 16 + AnimationTableStruct::tilesSize, X

	JSR	SimpleLoadTiles
	IF_C_SET
_Activated_NoLoadTiles:
		; Tile Load successful.
		; Set animationFrameDelay to $00
		SEP	#$20
.A8
		STZ	z:EntityAnimationStruct::animationFrameDelay
		REP	#$20
.A16
	ENDIF

	RTS



; IN: DP - The EntityAnimationStruct address
.A16
.I16
ROUTINE	Inactivated

	; Remove vram slot
	; ----------------

	; Inverted code from incremental.
	.assert VRAM_SLOT_SIZE * 16 = 512, error, "Incorrect code for value"
	LDA	z:EntityAnimationStruct::tileVramWordAddress
	SUB	#GAMELOOP_OAM_TILES
	XBA
	TAX

	STZ	entityInVramSlots, X

	; Decrement palette counter
	LDA	z:EntityAnimationStruct::metaSpriteCharAttr, X
	AND	#OAM_CHARATTR_PALETTE_MASK
	XBA
	TAX

	DEC	paletteSlotsTable + PaletteSlotsTableStruct::count, X

	RTS



.A16
.I16
ROUTINE Process
	; ::TODO Stagger the processing.::
	; ::: Currently the first has priority and will update more often then the others. ::
	; ::: Need to think about this one. ::

	LDX	#(N_VRAM_SLOTS - 1) * 2
	REPEAT
		LDA	entityInVramSlots, X
		IF_NOT_ZERO
			STX	processSlotsPosition

			TCD

			SEP	#$20
.A8
			LDA	z:EntityAnimationStruct::animationFrameDelay
			IF_NOT_ZERO
				CMP	#$FF
				IF_EQ
					; Tiles are still not loaded.
					REP	#$20
.A16
					JSR	InitialTileLoad
				ELSE
.A8
					; Currently waiting.
					DEC
					STA	z:EntityAnimationStruct::animationFrameDelay
				ENDIF
			ELSE
BytecodeNext:
				REP	#$30
.A16
.I16
				LDX	z:EntityAnimationStruct::animationPC
				TXY
				INY

				LDA	f:AnimationBank << 16, X
				AND	#$00FE
				TAX

				JMP	(.loword(BytecodeFunctionTable), X)
			ENDIF

; A/I size unknown
BytecodeEnd:
			REP	#$30
.A16
.I16
			LDX	processSlotsPosition
		ENDIF

		DEX
		DEX
	UNTIL_MINUS

	RTS


; ENTITY API
; ==========

; IN:	DP - EntityAnimationStruct address
; 	A - Animation ID
.A16
.I16
ROUTINE SetAnimation
	SEP	#$20
.A8
	CMP	z:EntityAnimationStruct::animationId
	REP	#$30
.A16
.I16
	IF_NE
		; entity->animationFrameDelay = 0
		; entity->animationPC = AnimationTableBank[entity->animationTable].bytecodePtr[entity->animationId]
		.assert EntityAnimationStruct::animationId + 1 = EntityAnimationStruct::animationFrameDelay, error, "Bad Order"
		AND	#$00FF
		STA	z:EntityAnimationStruct::animationId

		ASL
		ADD	z:EntityAnimationStruct::animationTable
		TAX

		LDA	f:AnimationTableBank << 16 + AnimationTableStruct::bytecodePtr, X
		STA	z:EntityAnimationStruct::animationPC
	ENDIF

	RTS



; IN:	DP - EntityAnimationStruct address
; OUT:	Z set if the current bytecode is stop.
.A16
.I16
ROUTINE IsAnimationStopped
	LDA	z:EntityAnimationStruct::animationFrameDelay
	AND	#$00FF
	IF_EQ
		LDX	z:EntityAnimationStruct::animationPC
		LDA	f:AnimationBank << 16, X
		AND	#$00FE
	ENDIF

	.assert AnimationBytecode::STOP = 0, error, "Bad Value"

	RTS



; BYTECODE
; ========
;
; INPUT:
;	Y - {`EntityAnimationStruct::animationPC` + 1}
;	DP - EntityAnimationStruct address
;
; Bytecode routines MUST SET `EntityAnimationStruct::animationPC` to
; the location of the next bytecode
;
; Bytecode routines can exit with any Accumulator/Index size
;
; They exit by branching to either:
;	BytecodeEnd - stop processing this entity's animation bytecode
;	BytecodeNext - continue processing the next bytecode.

.rodata

LABEL BytecodeFunctionTable
	.addr	BC_Stop
	.addr	BC_SetFrame
	.addr	BC_WaitFrames
	.addr	BC_Goto

.code

; DP = EntityAnimationStruct address
; Y = animationPC + 1
.A16
.I16
ROUTINE BC_Stop
	BRA	BytecodeEnd



; DP = EntityAnimationStruct address
; Y = animationPC + 1
.A16
.I16
ROUTINE BC_SetFrame
	TYX
	LDA	f:AnimationBank << 16, X
	STA	z:EntityAnimationStruct::metaSpriteFrame

	INX
	INX
	STX	z:EntityAnimationStruct::animationPC

	BRA	BytecodeNext



; DP = EntityAnimationStruct address
; Y = animationPC + 1
.A16
.I16
ROUTINE BC_WaitFrames
	SEP	#$20
.A8
	TYX
	LDA	f:AnimationBank << 16, X
	STA	z:EntityAnimationStruct::animationFrameDelay

	INX
	STX	z:EntityAnimationStruct::animationPC

	BRA	BytecodeEnd



; DP = EntityAnimationStruct address
; Y = animationPC + 1
.A16
.I16
ROUTINE BC_Goto
	TYX
	LDA	f:AnimationBank << 16, X
	STA	z:EntityAnimationStruct::animationPC

	BRA	BytecodeEnd


; ::MAYDO SetPalette::
; ::: remember the refence of the old palette::


; COMMON
; ======


;; Preps a simple block copy of the tiles to VRAM
;; INPUT:
;;	A - tile size
;;	Y - tile ptr
;; OUT:
;;	C set if successful, C clear is not enough DMA time
.A16
.I16
ROUTINE SimpleLoadTiles
	CMP	vramBufferBytesLeft
	IF_LT
		LDX	vramBufferPos
		CPX	#N_VRAM_TRANSFERS * 2
		IF_LT
			STA	vramBuffer_Size, X

			TYA
			TXY
			STA	vramBuffer_DataPtr, Y

			LDA	z:EntityAnimationStruct::tileVramWordAddress
			STA	vramBuffer_VramWordAddress, Y

			LDX	z:EntityAnimationStruct::animationTable
			LDA	f:AnimationTableBank << 16 + AnimationTableStruct::dataBank, X
			AND	#$00FF
			STA	vramBuffer_BankAndType, Y

			LDA	vramBufferBytesLeft
			SBC	vramBuffer_Size, Y		; don't worry about carry, this is approximate.
			STA	vramBufferBytesLeft

			INY
			INY
			STY	vramBufferPos

			SEC
			RTS
		ENDIF
	ENDIF

	CLC
	RTS



;; Loads the palette at palettePtr into CGRAM, sets palette bits in Entity's `metaSpriteCharAttr`
;; REQUIRE: 16 bit A, 16 bit Index
;; IN: A - palettePtr
.A16
.I16
ROUTINE LoadPalette
	LDX	#$FFFF
	STX	firstFreeSlot

	LDX	#(N_PALETTE_SLOTS - 1) * 2
	REPEAT
		CMP	paletteSlotsTable + PaletteSlotsTableStruct::palettePtr, X
		BEQ	_FoundExistingPaletteSlot

		LDY	paletteSlotsTable + PaletteSlotsTableStruct::count, X
		IF_ZERO
			STX	firstFreeSlot
		ENDIF
		DEX
		DEX
	UNTIL_MINUS

	LDX	firstFreeSlot
	IF_N_CLEAR
		STA	paletteSlotsTable + PaletteSlotsTableStruct::palettePtr, X

		; add to buffer for updating during VBlank
		LDY	cgramBufferPos
		STA	cgramBuffer_DataAddress, Y

		TXA					; x is palette * 2
		ASL					; 4
		ASL					; 8
		ASL					; 16
		ORA	#$81
		STA	cgramBuffer_StartingColor, Y

		INY
		INY
		STY	cgramBufferPos

_FoundExistingPaletteSlot:
		INC	paletteSlotsTable + PaletteSlotsTableStruct::count, X

		TXA					; x is palette * 2
		XBA					; set palette to bit 9
		STA	tmp
		LDA	z:EntityAnimationStruct::metaSpriteCharAttr
		AND	#OAM_CHARATTR_PALETTE_MASK ^ $FFFF
		ORA	tmp
		STA	z:EntityAnimationStruct::metaSpriteCharAttr
	ELSE
		; No Slots Available - Just ignore it.
		; ::SHOULD error handling::
	ENDIF

	RTS




.segment ANIMATION_PALETTE_BANK
	.exportzp EntityAnimation__PaletteDataBank = .bankbyte(*)

.segment ANIMATION_TABLE_BANK
	AnimationTableBank = .bankbyte(*)

.segment ANIMATION_BANK
	AnimationBank = .bankbyte(*)

ENDMODULE
