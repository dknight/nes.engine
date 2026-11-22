.import oam_begin
.import oam_end
.import sprite_clear_oam
.import player_draw
.import enemies_draw
.import objects_draw

.export render

.segment "CODE"

;==========================================================================
; Render the player, enemies, and objects to OAM, then transfer OAM to PPU.
;
; Input:
;   None
;
; Output:
;   OAM buffer submitted to the PPU.
;
; Clobbers:
;   A, X, Y
;
; Uses:
;   oam
;   oam_cursor
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
