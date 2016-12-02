; Castle Platformer Tileset arrangement.

CastlePlatformer_MetaTilePropertyTable:
	.byte	VramDataFormat::UNCOMPRESSED
	.word	CastlePlatformer_MetaTilePropertyTable_End - CastlePlatformer_MetaTilePropertyTable - 3


	; row 0
	.addr	TileProperties__EmptyTile
	.repeat 6
		.addr	TileProperties__Platform
	.endrepeat
	.addr	TileProperties__EmptyTile
	.repeat	3
		.addr	TileProperties__Platform
	.endrepeat
	.repeat	5
		.addr	TileProperties__EmptyTile
	.endrepeat
	; row 1
	.addr	TileProperties__SolidTile
	.addr	TileProperties__SolidTile
	.addr	TileProperties__StandingEventTile
	.addr	TileProperties__SolidTile
	.repeat 4
		.addr	TileProperties__Spikes
	.endrepeat
	.repeat 8
		.addr	TileProperties__EmptyTile
	.endrepeat
	; row 2
	.addr	TileProperties__StandingEventTile
	.repeat 3
		.addr	TileProperties__SolidTile
	.endrepeat
	.repeat 4
		.addr	TileProperties__Spikes
	.endrepeat
	.repeat 8
		.addr	TileProperties__EmptyTile
	.endrepeat
	; rows 3 - 5
	.repeat 3
		.repeat 7
			.addr	TileProperties__SolidTile
		.endrepeat
		.addr	TileProperties__Spikes
		.addr	TileProperties__SolidTile
		.repeat 7
			.addr	TileProperties__EmptyTile
		.endrepeat
	.endrepeat
	; row 6
	.repeat 7
		.addr	TileProperties__SolidTile
	.endrepeat
	.addr	TileProperties__Spikes
	.repeat 8
		.addr	TileProperties__EmptyTile
	.endrepeat
	; row 7
	.repeat 7
		.addr	TileProperties__SolidTile
	.endrepeat
	.repeat 9
		.addr	TileProperties__EmptyTile
	.endrepeat
	; rows 8 - 9
	.repeat 2
		.repeat 5
			.addr	TileProperties__SolidTile
		.endrepeat
		.addr	TileProperties__EmptyTile
		.addr	TileProperties__Chain
		.addr	TileProperties__Chain
		.repeat 8
			.addr	TileProperties__EmptyTile
		.endrepeat
	.endrepeat
	; rows 10 - 11
	.repeat 2
		.repeat 5
			.addr	TileProperties__SolidTile
		.endrepeat
		.repeat 11
			.addr	TileProperties__EmptyTile
		.endrepeat
	.endrepeat
	; rows 12 - 13
	.repeat 2
		.repeat 6
			.addr	TileProperties__SolidTile
		.endrepeat
		.repeat 10
			.addr	TileProperties__EmptyTile
		.endrepeat
	.endrepeat
	; row 14
	.repeat 4
		.addr	TileProperties__SolidTile
	.endrepeat
	.addr	TileProperties__StandingEventTile
	.addr	TileProperties__Spikes
	.repeat 10
		.addr	TileProperties__EmptyTile
	.endrepeat
	; row 15	
	.repeat 6
		.addr	TileProperties__IcePlatform
	.endrepeat
	.repeat 10
		.addr	TileProperties__EmptyTile
	.endrepeat

CastlePlatformer_MetaTilePropertyTable_End:

; vim: ft=asm:

