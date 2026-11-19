.include "tiles.inc"

.segment "TILES"

tiles_start:
	.incbin  "../../assets/patterns.chr"

tiles_end:
	; nop

.assert (tiles_end - tiles_start) = $2000, error, "CHR ROM must be exactly 8192 bytes"

.segment "RODATA"

.export tile_to_chr

; Related to maps level by index
tile_to_chr:
	.byte TILE_NOT_USED ; lavel map 0
	.byte TILE_FLOOR    ; level map 1
	.byte TILE_WALL     ; level map 2, etc.

tile_to_chr_end:
	; nop

.assert(tile_to_chr_end - tile_to_chr) = 3, error, "Invalid tiles mapping table size"

