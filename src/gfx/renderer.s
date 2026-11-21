.import oam_begin
.import oam_end
.import sprite_clear_oam
.import player_draw
.import enemies_draw
.import objects_draw

.export render

.segment "CODE"

;==========================================================================
; Simple renderer engine
;==========================================================================
.proc render
	JSR oam_begin
	JSR sprite_clear_oam

	JSR player_draw
	JSR enemies_draw
	JSR objects_draw

	JSR oam_end

	RTS
.endproc

