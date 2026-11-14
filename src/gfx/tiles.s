;==========================================================================
; Import pattern CHR data (tiles)
;==========================================================================
.segment "TILES"

tiles_start:
	.incbin  "../../assets/patterns.chr"

tiles_end:
	; nop

.assert (tiles_end - tiles_start) = $2000, error, "CHR ROM must be exactly 8192 bytes"

.segment "RODATA"

.export tile_to_chr

tile_to_chr:
	.byte $00 ; TILE_NOT_USED
	.byte $A0 ; TILE_FLOOR
	.byte $A2 ; TILE_WALL

tile_to_chr_end:
	; nop

.assert(tile_to_chr_end - tile_to_chr) = 3, error, "Invalid tiles mapping table size"

