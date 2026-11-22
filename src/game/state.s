.include "game.inc"

.exportzp game_state
.exportzp game_flags
.export state_init
.export state_set
.export state_check
.export state_set_flags
.export state_clear_flags
.export state_check_flags

.segment "ZEROPAGE"

game_state: .res 1
game_flags: .res 1

.segment "CODE"
;==========================================================================
; Initialize the game state and clear all game flags.
;
; Input:
;   None
;
; Output:
;   game_state = GAME_STATE_TITLE
;   game_flags = $00
;
; Clobbers:
;   A
;
; Uses:
;   game_state
;   game_flags
;==========================================================================
.proc state_init
	LDA #GAME_STATE_TITLE
	STA game_state

	LDA #$00
	STA game_flags

	RTS
.endproc

;==========================================================================
; Set the current game state.
;
; Input:
;   A = new game state
;
; Output:
;   game_state updated.
;
; Clobbers:
;   A
;
; Uses:
;   game_state
;==========================================================================
.proc state_set
	STA game_state
	RTS
.endproc

;==========================================================================
; Compare the current game state with the value in A.
;
; Input:
;   A = game state to compare
;
; Output:
;   Z = 1 if states are equal.
;   Z = 0 otherwise.
;
; Clobbers:
;   P (status flags)
;
; Uses:
;   game_state
;==========================================================================
.proc state_check
	CMP game_state
	RTS
.endproc

;==========================================================================
; Set the game flags selected by the mask in A.
;
; Input:
;   A = flag mask
;
; Output:
;   Specified flags set in game_flags.
;
; Clobbers:
;   A
;
; Uses:
;   game_flags
;==========================================================================
.proc state_set_flags
	ORA game_flags
	STA game_flags
	RTS
.endproc

;==========================================================================
; Clear the game flags selected by the mask in A.
;
; Input:
;   A = flag mask
;
; Output:
;   Specified flags cleared in game_flags.
;
; Clobbers:
;   A
;
; Uses:
;   game_flags
;==========================================================================
.proc state_clear_flags
	EOR #$FF
	AND game_flags
	STA game_flags
	RTS
.endproc

;==========================================================================
; Test whether any game flags selected by the mask in A are set.
;
; Input:
;   A = flag mask
;
; Output:
;   Z = 1 if none of the specified flags are set.
;   Z = 0 if any specified flag is set.
;
; Clobbers:
;   A, P (status flags)
;
; Uses:
;   game_flags
;==========================================================================
.proc state_check_flags
	AND game_flags
	RTS
.endproc
