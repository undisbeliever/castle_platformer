.ifndef ::_ENTITY_ANIMATION_H_
::_ENTITY_ANIMATION_H_ = 1

;; Entity Animation module.
;;
;; This module is responsible for setting the `metaSpriteCharAttr` and
;; `metaSpriteFrame` variables of an entity.
;;
;; Each entity is allocated 2 VRAM tile rows (32 8x8 tiles) upon Entity
;; Actiavtion.
;;
;; Palettes can be shared across multiple entities.
;; The system will automatcally allocate/unallocate the palettes using
;; reference counting. Palettes with the same `palettePtr` value will use
;; the the same palette in CGRAM.
;;
;; When an Entity is activated the tiles stored in `AnimationTable::tilesPtr`
;; will be loaded into VRAM. This value can be NULL, in which case it
;; is skipped.
;;
;; The module uses a bytecode format in order to describe how the metasprite
;; frames/tiles/palettes are loaded into the system.
;;
;; If there is not enough DMA time to load the tiles, the bytecode will pause
;; execution and skipped until next frame.


.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

.include "entity.h"

;; Bank in which the animation table resides
; ::TODO make configurable::
.define ANIMATION_TABLE_BANK "BANK1"
.define ANIMATION_BANK "BANK1"
.define METASPRITE_FRAME_BANK "BANK1"
.define ANIMATION_PALETTE_BANK "BANK2"

;; Number of bytes to transfer during DMA::
; ::TODO make configurable::
ANIMATION_DMA_TRANSFER_BYTES = 4096


.struct AnimationTableStruct
	;; The Data bank the tiles are loaded
	dataBank		.byte
	;; The address of the initial tiles (with `dataBank`) to load.
	;; May be NULL (0), if so then no tiles are loaded.
	tilesPtr		.addr
	;; Number of bytes to transfer for the initial state.
	;; MUST be less than or equal to 1024.
	tilesSize		.word

	;; The address of the palette (within `ANIMATION_PALETTE_BANK`) to load
	;; Copies 15 bytes no matter what
	palettePtr		.byte

	;; The animation bytecode to process for each `Animation`
	;; Continues to the end.
	bytecode		.addr
.endstruct

.enum AnimationBytecode
	STOP		= 0
	SET_FRAME	= 2
	WAIT_FRAMES	= 4
	; ::SHOULDO add WAIT_SPEED_FRAMES::
	; :::Waits {argument - abs(xVecl)} frames (like sonic does)::
	GOTO		= 6
.endenum


;; This macro simplifies the creation of the MetaSprite tables
;;
;; PARAMS:	xPos - x position
;;		yPos - y position
;;      	size - the size of the sprite (BIG or SMALL) (optional)
;;		priority - sprite priority (optional)
;;		oamAttrFlags - OBJ attr byte to append (optional)
.macro MetaSprite xPos, yPos, char, size, priority, oamAttrFlags
	.if .blank(size)
		MetaSprite xPos, yPos, char, SMALL, 2, oamAttrFlags
	.elseif .blank(priority)
		MetaSprite xPos, yPos, char, size, 2, oamAttrFlags
	.elseif .blank(oamAttrFlags)
		MetaSprite xPos, yPos, char, size, 2, 0
	.else
		.assert priority >= 0 .or priority <= 3, error, "priority must be 0 - 3"

		.byte	.lobyte(xPos)
		.byte	.lobyte(yPos)
		.word	char | (priority << OAM_CHARATTR_ORDER_SHIFT) | (oamAttrFlags << 8)

		.if .xmatch(size, BIG)
			.byte	$FF
		.elseif .xmatch(size, SMALL)
			.byte	$00
		.else
			.fatal .sprintf("Unknown size %s, expected BIG or SMALL", .string(size))
		.endif
	.endif
.endmacro

.define MS_HFLIP OAM_ATTR_H_FLIP_FLAG
.define MS_VFLIP OAM_ATTR_V_FLIP_FLAG


.macro ENTITY_ANIMATION_STRUCT name
	ENTITY_STRUCT name
		;; Address of the AnimationTableStruct within `ANIMATION_TABLE_BANK`
		animationTable		.addr

		;; current location (within `ANIMATION_BANK` of the Animation Metatile bank format
		animationPC		.addr

		;; Word address of tiles in VRAM
		tileVramWordAddress	.word

		;; Number of frames to wait to the next animation ByteCode
		;; If $FF, then character is not loaded into VRAM.
		animationFrameDelay	.byte

		;; The current animation ID
		animationId		.byte
.endmacro
.define END_ENTITY_ANIMATION_STRUCT END_ENTITY_STRUCT

ENTITY_ANIMATION_STRUCT EntityAnimationStruct
END_ENTITY_ANIMATION_STRUCT


IMPORT_MODULE EntityAnimation
	;; Sets up the state tables.
	;; Called when the map is initiaised.
	;; REQUIRE: 16 bit A, 16 bit Index, DB = $7E
	ROUTINE Init

	;; Sets up the entities tiles.
	;; MUST be called when the entity is activated on the screen.
	;;
	;; REQUIRE: 16 bit A, 16 bit Index, DB = $7E
	;; INPUT: DP = the EntityAnimationStruct address
	ROUTINE Activated

	;; Deallocates the current titities tiles from VRAM if neccessary
	;; MUST be called when the entity is removed from the active list
	;; (offscreen or dead)
	;;
	;; REQUIRE: 16 bit A, 16 bit Index, DB = $7E
	;; INPUT: DP = the EntityAnimationStruct address
	ROUTINE Inactivated

	;; Processes the entities animations
	;; MUST be called before `Entities__Process` and after `MetaTiles1x16__Update`
	;; REQUIRE: 16 bit A, 16 bit Index, DB = $7E
	ROUTINE Process


	;; Updates the buffers into VRAM/CGRAM.
	;; REQUIRES: 8 bit A, 16 bit Index, DB access registers
	.macro EntityAnimation_VBlank
		.export _EntityAnimation_VBlank__Called = 1


		.global EntityAnimation__cgramBufferPos
		.global EntityAnimation__cgramBuffer_DataAddress
		.global EntityAnimation__cgramBuffer_StartingColor
		.globalzp EntityAnimation__PaletteDataBank

		LDX	EntityAnimation__cgramBufferPos
		IF_NOT_ZERO
			LDY	#DMAP_DIRECTION_TO_PPU | DMAP_TRANSFER_WRITE_TWICE | (.lobyte(CGDATA) << 8)
			STY	DMAP0			; also sets BBAD0

			LDA	#EntityAnimation__PaletteDataBank
			STA	A1B0

			REPEAT
				LDA	EntityAnimation__cgramBuffer_StartingColor - 2, X
				STA	CGADD

				LDY	EntityAnimation__cgramBuffer_DataAddress - 2, X
				STY	A1T0

				LDY	#15 * 2
				STY	DAS0

				LDA	#MDMAEN_DMA0
				STA	MDMAEN

				DEX
				DEX
			UNTIL_ZERO

			STX	EntityAnimation__cgramBufferPos
		ENDIF

		.global	EntityAnimation__vramBufferPos
		.global	EntityAnimation__vramBufferBytesLeft
		.global	EntityAnimation__vramBuffer_BankAndType
		.global	EntityAnimation__vramBuffer_DataPtr
		.global	EntityAnimation__vramBuffer_Size
		.global	EntityAnimation__vramBuffer_VramWordAddress

		LDX	EntityAnimation__vramBufferPos
		IF_NOT_ZERO
			LDA	#VMAIN_INCREMENT_HIGH | VMAIN_INCREMENT_1
			STA	VMAIN

			LDY	#DMAP_DIRECTION_TO_PPU | DMAP_TRANSFER_2REGS | (.lobyte(VMDATA) << 8)
			STY	DMAP0			; also sets BBAD0

			REPEAT
				; get type
				LDA	EntityAnimation__vramBuffer_BankAndType + 1 - 2, X
				IF_ZERO
					LDA	EntityAnimation__vramBuffer_BankAndType - 2, X
					STA	A1B0

					LDY	EntityAnimation__vramBuffer_DataPtr - 2, X
					STY	A1T0

					LDY	EntityAnimation__vramBuffer_Size - 2, X
					STY	DAS0

					LDY	EntityAnimation__vramBuffer_VramWordAddress - 2, X
					STY	VMADD

					LDA	#MDMAEN_DMA0
					STA	MDMAEN
				ELSE
					; ::TODO other formats::
				ENDIF

				DEX
				DEX
			UNTIL_ZERO

			STX	EntityAnimation__vramBufferPos

			LDX	#ANIMATION_DMA_TRANSFER_BYTES
			STX	EntityAnimation__vramBufferBytesLeft
		ENDIF
	.endmacro
ENDMODULE

.endif ; ::_ENTITY_ANIMATION_H_

; vim: set ft=asm:

