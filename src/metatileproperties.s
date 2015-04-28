
.include "metatileproperties.h"
.include "includes/import_export.inc"

.include "physics.h"

.segment "BANK1"

MetaTilePropertyBank = .bankbyte(*)

MODULE TileProperties

	.assert .loword(*) <> 0, lderror, "TileProperties addresses MUST NOT be 0"

	LABEL	EmptyTile
	LABEL	Chain
		.word	$0000		; type
		.word	0		; friction
		.word	20		; walkAcceleration
		.word	.loword(-512)	; minimumXVelocity
		.word	512		; maximumXVelocity
		.word	0		; jumpingVelocity

	LABEL	SolidTile
	LABEL	Spikes
	LABEL	Switch
		.word	$0001		; type
		.word	20		; friction
		.word	80		; walkAcceleration
		.word	.loword(-512)	; minimumXVelocity
		.word	512		; maximumXVelocity
		.word	.loword(-1024)	; jumpingVelocity

	LABEL	Platform
		.word	$FFFF		; type
		.word	20		; friction
		.word	80		; walkAcceleration
		.word	.loword(-512)	; minimumXVelocity
		.word	512		; maximumXVelocity
		.word	.loword(-1024)	; jumpingVelocity

	LABEL	IcePlatform
		.word	$FFFF		; type
		.word	2		; friction
		.word	60		; walkAcceleration
		.word	.loword(-512)	; minimumXVelocity
		.word	512		; maximumXVelocity
		.word	.loword(-896)	; jumpingVelocity

ENDMODULE

