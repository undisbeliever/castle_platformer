
.include "metatileproperties.h"
.include "includes/import_export.inc"

.include "entity-physics.h"
.include "interactive-metatiles/spikedtile.h"
.include "interactive-metatiles/standing-event-tile.h"

.segment "BANK1"

MetaTilePropertyBank = .bankbyte(*)

MAX_WALK       = 512
WALK_ACCEL     = 24
FRICTION       = 16
AIR_FRICTION   = FRICTION / 2
AIR_ACCEL      = WALK_ACCEL
ICE_MAX_WALK   = MAX_WALK
ICE_WALK_ACCEL = 8
ICE_FRICTION   = 2


MODULE TileProperties

	.assert .loword(*) <> 0, lderror, "TileProperties addresses MUST NOT be 0"

	LABEL	EmptyTile
		.word	$0000				; type
		.addr	0				; functionsTable
		.word	AIR_FRICTION			; friction
		.word	AIR_ACCEL			; walkAcceleration
		.word	.loword(-MAX_WALK)		; minimumXVelocity
		.word	MAX_WALK			; maximumXVelocity
		.word	0				; jumpingVelocity

	LABEL	Chain
	LABEL	SolidTile
		.word	$0001				; type
		.addr	0				; functionsTable
		.word	FRICTION			; friction
		.word	WALK_ACCEL + FRICTION		; walkAcceleration
		.word	.loword(-MAX_WALK)		; minimumXVelocity
		.word	MAX_WALK			; maximumXVelocity
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
		.word	FRICTION			; friction
		.word	WALK_ACCEL + FRICTION		; walkAcceleration
		.word	.loword(-MAX_WALK)		; minimumXVelocity
		.word	MAX_WALK			; maximumXVelocity
		.word	.loword(-1024)			; jumpingVelocity

	LABEL	StandingEventTile
		.word	$FFFF				; type
		.addr	StandingEventTile__functionsTable ; functionsTable
		.word	FRICTION			; friction
		.word	WALK_ACCEL + FRICTION		; walkAcceleration
		.word	.loword(-MAX_WALK)		; minimumXVelocity
		.word	MAX_WALK			; maximumXVelocity
		.word	.loword(-1024)			; jumpingVelocity

	LABEL	IcePlatform
		.word	$FFFF				; type
		.addr	0				; functionsTable
		.word	ICE_FRICTION			; friction
		.word	ICE_WALK_ACCEL + ICE_FRICTION	; walkAcceleration
		.word	.loword(-ICE_MAX_WALK)		; minimumXVelocity
		.word	ICE_MAX_WALK			; maximumXVelocity
		.word	.loword(-1000)			; jumpingVelocity


ENDMODULE

