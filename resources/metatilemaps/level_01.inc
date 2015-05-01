; StandingEvent tile locations and parameters.
; ::TODO generate by program::

Level01_InteractiveTilesStruct:
	.addr	Level01_StandingEventsTileTable		; standingEventsTablePtr
	.word	Level01_StandingEventsTileTable_Count	; standingEventsTableCount


Level01_StandingEventsTileTable:
	;	minMapLocation      , minMapLocation      , command                             , parameter
	.word	(13 * 112 + 28) * 2 , (13 * 112 + 31) * 2 , StandingEventsCommand::REMOVE_CHAIN , (13 * 112 + 33) * 2
	.word	(26 * 112 + 29) * 2 , (26 * 112 + 32) * 2 , StandingEventsCommand::REMOVE_CHAIN , (12 * 112 + 94) * 2
	.word	(51 * 112 + 45) * 2 , (51 * 112 + 48) * 2 , StandingEventsCommand::REMOVE_CHAIN , (12 * 112 + 97) * 2
	.word	(13 * 112 + 100) * 2, (13 * 112 + 109) * 2, StandingEventsCommand::REMOVE_BRIDGE, (13 * 112 + 100) * 2
	.word	(52 * 112 + 100) * 2, (52 * 112 + 109) * 2, StandingEventsCommand::GAME_OVER    , 0

Level01_StandingEventsTileTable_Count = (* - Level01_StandingEventsTileTable) / .sizeof(StandingEventsTableStruct)


; vim: ft=asm:

