.include "tiles.inc"

.segment "TILES"

tiles_start:
	.incbin  "../../assets/patterns.chr"

tiles_end:
	; nop

.assert (tiles_end - tiles_start) = $2000, error, "CHR ROM must be exactly 8192 bytes"

.segment "RODATA"

.export tile_to_chr

tile_to_chr:
	.byte TILE_NOT_USED
	.byte TILE_FLOOR
	.byte TILE_WALL

tile_to_chr_end:
	; nop

.assert(tile_to_chr_end - tile_to_chr) = 3, error, "Invalid tiles mapping table size"

