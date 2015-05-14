; StandingEvent tile locations and parameters.
; ::TODO generate by program::

.segment MAP_PROPERTIES_BANK

Level01_MapPropertiesStruct:
	.byte	TILESET_CASTLE_PLATFORMER		; tileset
	.word	0					; xPos
	.word	0					; yPos
	.addr	Level01_MapEntitiesTable		; mapEntitiesTable
	.word	Level01_MapEntitiesTable_Count		; mapEntitiesTableCount
	.addr	Level01_StandingEventsTileTable		; standingEventsTablePtr
	.word	Level01_StandingEventsTileTable_Count	; standingEventsTableCount

.segment MAP_ENTITIES_TABLE_BANK

Level01_MapEntitiesTable:
	;	xPos,	yPos,	parameter,	entityState
	; first Entity is player
	.word 	80,	216,	0,		.loword(Player__InitState)
	; rest are NPCs

	.word 	336,	216,	0,		.loword(Npc_WalkAndTurn__WalkLeft)
	.word 	600,	216,	0,		.loword(Npc_WalkAndTurn__WalkLeft)
	.word 	744,	168,	0,		.loword(Npc_WalkAndTurn__WalkLeft)
	.word 	1672,	200,	0,		.loword(Npc_WalkAndTurn__WalkLeft)

	.word 	192,	552,	16,		.loword(Npc_WalkAndTurn__WalkLeft)
	.word 	192,	552,	16,		.loword(Npc_WalkAndTurn__WalkRight)

	.word 	192,	648,	16,		.loword(Npc_WalkAndTurn__WalkLeft)
	.word 	192,	648,	16,		.loword(Npc_WalkAndTurn__WalkRight)

Level01_MapEntitiesTable_Count = (* - Level01_MapEntitiesTable) / .sizeof(MapEntitiesTableStruct)


.segment STANDING_EVENTS_TABLE_BANK

Level01_StandingEventsTileTable:
	;	minMapLocation      , minMapLocation      , command                             , parameter
	.word	(13 * 112 + 28) * 2 , (13 * 112 + 31) * 2 , StandingEventsCommand::REMOVE_CHAIN , (13 * 112 + 33) * 2
	.word	(26 * 112 + 29) * 2 , (26 * 112 + 32) * 2 , StandingEventsCommand::REMOVE_CHAIN , (12 * 112 + 94) * 2
	.word	(51 * 112 + 45) * 2 , (51 * 112 + 48) * 2 , StandingEventsCommand::REMOVE_CHAIN , (12 * 112 + 97) * 2
	.word	(13 * 112 + 100) * 2, (13 * 112 + 109) * 2, StandingEventsCommand::REMOVE_BRIDGE, (13 * 112 + 100) * 2
	.word	(52 * 112 + 100) * 2, (52 * 112 + 109) * 2, StandingEventsCommand::GAME_OVER    , 0

Level01_StandingEventsTileTable_Count = (* - Level01_StandingEventsTileTable) / .sizeof(StandingEventsTableStruct)

; vim: ft=asm:

