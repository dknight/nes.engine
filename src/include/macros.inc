;==========================================================================
; Convert pixel coordinate in A to tile coordinate.
;==========================================================================
.macro macro_pixel_to_tile
	LSR
	LSR
	LSR
.endmacro

; This is very simple debugger, it doesn't stop program loop, but do not
; change register values.
.if DEBUG
	.macro DEBUG_BREAK
			 @debug:
				JMP @debug
	.endmacro
.else
	.macro DEBUG_BREAK
	.endmacro
.endif

