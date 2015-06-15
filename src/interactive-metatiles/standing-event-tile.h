.ifndef ::_STANDING_EVENT_TILE_H_
::_STANDING_EVENT_TILE_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

; ::SHOULDDO make configurable::
;; segment that contains the standing event table
.define STANDING_EVENTS_TABLE_BANK "BANK1"

; A switchtile only handles a horizontal row of tiles
.struct StandingEventsTableStruct
	minMapLocation	.addr
	maxMapLocation	.addr
	command		.addr
	parameter	.word
.endstruct

.enum StandingEventsCommand
	;; Removes the chain incrementally (upwards) while Rumbling the screen
	;; parameter: the address of the lowest tile of the chain.
	;;
	;; This command reconizes a chain tile as the tile *above* the parameter.
	;; It will stop when the it reaches the top of the map or the next tile
	;; to remove is not a chain tile.
	;;
	;; Thus a chain must be at least 2 tiles tall.
	REMOVE_CHAIN = 0

	;; Removes the chain incrementally (rightwards) while Rumbling the screen
	;; parameter: the address of the leftmost tile of the bridge.
	;;
	;; This command recognizes a bridge tile as the *first* tile removed.
	;; It will stop when the it reaches a tile that is not a bridge tile.
	REMOVE_BRIDGE = 2

	;; Extends a bridge left/right wards until it reaches
	;; parameter: the address of the tile of the bridge to extend.
	;; one of the tiles left/right wards of the bridge is 0, that is
	;; the direction of extension.
	EXTEND_BRIDGE = 4

	;; Sets the game loop state to GAME_OVER
	GAME_OVER = 6

	;; Stops the game loop and loads a new map
	LOAD_MAP = 8
.endenum

IMPORT_MODULE StandingEventTile
	;; The memory location within `MAP_PROPERTIES_BANK` of the StandingEventTile table
	;; ACCESS: WRAM7E
	ADDR	standingEventsTablePtr

	;; The number of entries in the StandingEventTile table
	;; ACCESS: WRAM7E
	WORD	standingEventsTableCount

	;; The MetaTileProperties function table for the switch table.
	LABEL	functionsTable
ENDMODULE

.endif ; ::_STANDING_EVENT_TILE_H_

; vim: set ft=asm:

