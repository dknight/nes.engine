.include "game.inc"

.importzp frame_ready
.importzp vblank_counter
.importzp game_timer

.export timers_update
.export wait_frame

.segment "CODE"

;==========================================================================
; Increment the VBlank counter and update the game timer.
;
; Input:
;   None
;
; Output:
;   vblank_counter incremented.
;   game_timer decremented or reloaded.
;
; Clobbers:
;   A
;
; Uses:
;   vblank_counter
;   game_timer
;==========================================================================
.proc timers_update
	INC vblank_counter

	LDA game_timer
	BEQ @reload

	DEC game_timer
	RTS
@reload:
	LDA #GAME_TIMER_COUNT
	STA game_timer
	RTS
.endproc

;==========================================================================
; Wait until the NMI handler signals a frame, then clear the flag.
;
; Input:
;   None
;
; Output:
;   frame_ready cleared.
;
; Clobbers:
;   A
;
; Uses:
;   frame_ready
;==========================================================================
.proc wait_frame
@wait:
	LDA frame_ready
	BEQ @wait

	LDA #$00
	STA frame_ready
	RTS
.endproc
