.ifndef ::_STANDING_EVENT_TILE_H_
::_STANDING_EVENT_TILE_H_ = 1

.setcpu "65816"

; Common includes
.include "includes/import_export.inc"
.include "includes/registers.inc"

; A switchtile only handles a horizontal row of tiles
.struct StandingEventsTableStruct
	minMapLocation	.addr
	maxMapLocation	.addr
	command		.addr
	parameter	.word
.endstruct

;; The bank that contains the switch tile table
.global StandingEventsTableBank : zp

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
	;; This command reconizes a bridge tile as the *first* tile removed.
	;; It will stop when the it reaches a tile that is not a bridge tile.
	REMOVE_BRIDGE = 2
.endenum

IMPORT_MODULE StandingEventTile
	;; The memory location within `StandingEventsTableBank` of the StandingEventTile table
	.global StandingEventTile__standingEventsTablePtr : far

	;; The number of entries in the StandingEventTile table
	.global StandingEventTile__standingEventsTableCount : far

	;; The MetaTileProperties function table for the switch table.
	LABEL	functionsTable
ENDMODULE

.endif ; ::_STANDING_EVENT_TILE_H_

; vim: set ft=asm:

