
.include "metatileproperties.h"
.include "includes/import_export.inc"

.include "entity-physics.h"
.include "interactive-metatiles/spikedtile.h"
.include "interactive-metatiles/standing-event-tile.h"

.segment "BANK1"

MetaTilePropertyBank = .bankbyte(*)

MAX_WALK       = $0140
MAX_RUN        = $0240
WALK_ACCEL     = $0018
FRICTION       = $0010
AIR_FRICTION   = FRICTION / 2
AIR_ACCEL      = WALK_ACCEL
ICE_MAX_WALK   = MAX_WALK
ICE_MAX_RUN    = MAX_RUN
ICE_WALK_ACCEL = $0008
ICE_FRICTION   = $0002
JUMP_VECL      = $0400

MODULE TileProperties

	.assert .loword(*) <> 0, lderror, "TileProperties addresses MUST NOT be 0"

	LABEL	EmptyTile
		.word	$0000				; type
		.addr	0				; functionsTable
		.word	AIR_FRICTION			; friction
		.word	AIR_ACCEL			; walkAcceleration
		.word	.loword(-MAX_WALK)		; minimumXWalkVelocity
		.word	MAX_WALK			; maximumXWalkVelocity
		.word	.loword(-MAX_RUN)		; minimumXVelocity
		.word	MAX_RUN				; maximumXVelocity
		.word	0				; jumpingVelocity

	LABEL	Chain
	LABEL	SolidTile
		.word	$0001				; type
		.addr	0				; functionsTable
		.word	FRICTION			; friction
		.word	WALK_ACCEL + FRICTION		; walkAcceleration
		.word	.loword(-MAX_WALK)		; minimumXWalkVelocity
		.word	MAX_WALK			; maximumXWalkVelocity
		.word	.loword(-MAX_RUN)		; minimumXVelocity
		.word	MAX_RUN				; maximumXVelocity
		.word	.loword(-JUMP_VECL)		; jumpingVelocity

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
		.word	.loword(-MAX_WALK)		; minimumXWalkVelocity
		.word	MAX_WALK			; maximumXWalkVelocity
		.word	.loword(-MAX_RUN)		; minimumXVelocity
		.word	MAX_RUN				; maximumXVelocity
		.word	.loword(-JUMP_VECL)		; jumpingVelocity

	LABEL	StandingEventTile
		.word	$FFFF				; type
		.addr	StandingEventTile__functionsTable ; functionsTable
		.word	FRICTION			; friction
		.word	WALK_ACCEL + FRICTION		; walkAcceleration
		.word	.loword(-MAX_WALK)		; minimumXWalkVelocity
		.word	MAX_WALK			; maximumXWalkVelocity
		.word	.loword(-MAX_RUN)		; minimumXVelocity
		.word	MAX_RUN				; maximumXVelocity
		.word	.loword(-JUMP_VECL)		; jumpingVelocity

	LABEL	IcePlatform
		.word	$FFFF				; type
		.addr	0				; functionsTable
		.word	ICE_FRICTION			; friction
		.word	ICE_WALK_ACCEL + ICE_FRICTION	; walkAcceleration
		.word	.loword(-ICE_MAX_WALK)		; minimumXWalkVelocity
		.word	ICE_MAX_WALK			; maximumXWalkVelocity
		.word	.loword(-ICE_MAX_RUN)		; minimumXVelocity
		.word	ICE_MAX_RUN			; maximumXVelocity
		.word	.loword(-JUMP_VECL)		; jumpingVelocity


ENDMODULE

