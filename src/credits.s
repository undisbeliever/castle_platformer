
.include "credits.h"
.include "includes/import_export.inc"
.include "includes/synthetic.inc"
.include "includes/registers.inc"
.include "includes/structure.inc"

.include "routines/screen.h"
.include "routines/block.h"

MODULE Credits

CREDITS_SCREEN_MODE	= BGMODE_MODE1
CREDITS_BG1_MAP 	= $0000
CREDITS_BG1_TILES	= $3000
CREDITS_BG1_SIZE	= BGXSC_SIZE_32X64


CREDITS_IMG_FRAME_DELAY = 4 * 60

.segment "SHADOW"
	WORD	tmp

.code

.A8
.I16
ROUTINE ShowCredits
	; Load Credits
	JSR	Screen__FadeOut

	LDA	#INIDISP_FORCE
	STA	INIDISP

	LDA	#CREDITS_SCREEN_MODE
	STA	BGMODE

	Screen_SetVramBaseAndSize CREDITS
	LDA	#INIDISP_FORCE
	STA	INIDISP

	STZ	BG1HOFS
	STZ	BG1HOFS

	LDA	#$FF
	STA	BG1VOFS
	STA	BG1VOFS

	TransferToVramLocation	CreditsMap, CREDITS_BG1_MAP
	TransferToVramLocation	CreditsTiles, CREDITS_BG1_TILES
	TransferToCgramLocation	CreditsPalette, 0

	LDA	#TM_BG1
	STA	TM

	JSR	Screen__FadeIn

	; Wait
	; ----

	FOR_Y	#CREDITS_IMG_FRAME_DELAY, DEC, #0
		PHY

		JSR	Screen__WaitFrame

		PLY
	NEXT


	; Scroll
	; ------
	FOR_Y	#0, INC, #512 - 224
		STY	tmp

		JSR	Screen__WaitFrame
		JSR	Screen__WaitFrame

		; ::HACK in VBlank::
		LDA	tmp
		STA	BG1VOFS
		LDA	tmp + 1
		STA	BG1VOFS

		LDY	tmp
	NEXT


	; Halt
	; ----
	REPEAT
		; using STP crashes some versions of snes9x
		WAI
	FOREVER

; from resources.s 
.import CreditsMap, CreditsMap_End
.import CreditsTiles, CreditsTiles_End
.import CreditsPalette, CreditsPalette_End

ENDMODULE

