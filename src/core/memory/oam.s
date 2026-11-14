;==========================================================================
; Sprite OAM Data area
;==========================================================================
.segment "OAM"

.export oam

oam:
	.res 256
oam_end:
	; nop

.assert (oam_end - oam) = 256, error, "OAM must be exactly 256 bytes"
.assert <oam = $00, error, "OAM must be page-aligned"

