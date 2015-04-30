
.include "metatileproperties.h"
.include "includes/import_export.inc"

.include "physics.h"
.include "interactive-metatiles/switchtile.h"
.include "interactive-metatiles/spikedtile.h"

.segment "BANK1"

MetaTilePropertyBank = .bankbyte(*)

MODULE TileProperties

	.assert .loword(*) <> 0, lderror, "TileProperties addresses MUST NOT be 0"

	LABEL	EmptyTile
		.word	$0000				; type
		.addr	0				; functionsTable
		.word	0				; friction
		.word	20				; walkAcceleration
		.word	.loword(-512)			; minimumXVelocity
		.word	512				; maximumXVelocity
		.word	0				; jumpingVelocity

	LABEL	SolidTile
	LABEL	Chain
		.word	$0001				; type
		.addr	0				; functionsTable
		.word	20				; friction
		.word	80				; walkAcceleration
		.word	.loword(-512)			; minimumXVelocity
		.word	512				; maximumXVelocity
		.word	.loword(-1024)			; jumpingVelocity

	LABEL	Spikes
		.word	$0000				; type
		.addr	SpikedTile__functionsTable	; functionsTable
		.word	0				; friction
		.word	0				; walkAcceleration
		.word	0				; minimumXVelocity
		.word	0				; maximumXVelocity
		.word	0				; jumpingVelocity

	LABEL	Platform
		.word	$FFFF				; type
		.addr	0				; functionsTable
		.word	20				; friction
		.word	80				; walkAcceleration
		.word	.loword(-512)			; minimumXVelocity
		.word	512				; maximumXVelocity
		.word	.loword(-1024)			; jumpingVelocity

	LABEL	Switch
		.word	$FFFF				; type
		.addr	SwitchTile__functionsTable	; functionsTable
		.word	20				; friction
		.word	80				; walkAcceleration
		.word	.loword(-512)			; minimumXVelocity
		.word	512				; maximumXVelocity
		.word	.loword(-1024)			; jumpingVelocity

	LABEL	IcePlatform
		.word	$FFFF				; type
		.addr	0				; functionsTable
		.word	2				; friction
		.word	60				; walkAcceleration
		.word	.loword(-512)			; minimumXVelocity
		.word	512				; maximumXVelocity
		.word	.loword(-1000)			; jumpingVelocity


ENDMODULE

