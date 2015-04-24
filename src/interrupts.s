; Inturrupt Handlers

.include "includes/registers.inc"
.include "includes/structure.inc"
.include "includes/synthetic.inc"
.include "routines/block.h"
.include "routines/screen.h"
.include "routines/metatiles/metatiles-1x16.h"

.include "controller.h"


;; Blank Handlers
ROUTINE IrqHandler
	RTI

ROUTINE CopHandler
	RTI

ROUTINE VBlank
	; Save state
	REP #$30
	PHA
	PHB
	PHD
	PHX
	PHY

	PHK
	PLB

	SEP #$20
.A8
.I16
	; Reset NMI Flag.
	LDA	RDNMI

	Screen_VBlank
	MetaTiles1x16_VBlank

	JSR	Controller__Update

	; Load State
	REP	#$30
	PLY
	PLX
	PLD
	PLB
	PLA

	RTI

