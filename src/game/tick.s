.import player_update
.import enemies_update
.import projectiles_update
.import camera_update

.export game_tick

.segment "CODE"

;==========================================================================
; Update all game systems for one game tick.
;
; Input:
;   None
;
; Output:
;   All game systems updated for one game tick.
;
; Clobbers:
;   A, X, Y
;
; Uses:
;   None
;==========================================================================
.proc game_tick
	JSR player_update
	JSR enemies_update
	JSR projectiles_update
	JSR camera_update
	RTS
.endproc
