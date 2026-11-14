.include "../core/constants.inc"

.segment "RODATA"

;==========================================================================
; Nametable is used for backgrounds
;==========================================================================

.export attribute_table

attribute_table:
	.repeat 64
		.byte $00
	.endrepeat

attribute_table_end:
	; nop

.assert (attribute_table_end - attribute_table) = 64, error, "Attribute table must be 64 bytes."
