.include "gfx.inc"

.importzp ptr_lo
.import dma_transfer
.import oam

.exportzp oam_cursor
.exportzp sprite_y
.exportzp sprite_tile
.exportzp sprite_attr
.exportzp sprite_x
.export sprite_clear_oam
.export oam_begin
.export oam_end
.export sprite_draw
.export sprite_draw_meta

.segment "ZEROPAGE"

oam_cursor:   .res 1

sprite_y:     .res 1
sprite_tile:  .res 1
sprite_attr:  .res 1
sprite_x:     .res 1

metasprite_x: .res 1
metasprite_y: .res 1

.segment "CODE"

;==========================================================================
; Fill the OAM shadow buffer with $FF to hide all sprites.
;
; Input:
;   None
;
; Output:
;   OAM shadow buffer filled with $FF.
;
; Clobbers:
;   A, X
;
; Uses:
;   oam
;==========================================================================
.proc sprite_clear_oam
	LDA #$FF
	LDX #$00

clear_loop:
	STA oam,X
	
	INX
	INX
	INX
	INX
	
	BNE clear_loop
	
	RTS
.endproc

;==========================================================================
; Begin an OAM update by resetting the OAM cursor.
;
; Input:
;   None
;
; Output:
;   OAM cursor reset to zero.
;
; Clobbers:
;   A
;
; Uses:
;   oam_cursor
;==========================================================================
.proc oam_begin
	LDA #$00
	STA oam_cursor
	RTS
.endproc

;==========================================================================
; Transfer the OAM shadow buffer to PPU OAM using DMA.
;
; Input:
;   None
;
; Output:
;   OAM shadow buffer copied to PPU OAM.
;
; Clobbers:
;   A
;
; Uses:
;   oam
;==========================================================================
.proc oam_end
	JSR dma_transfer
	RTS
.endproc

;==========================================================================
; Draw a single 8x8 hardware sprite (OAM format: Y, TILE, ATTR, X).
;
; Input:
;   A - Y coordinate
;   X - CHR tile index
;   Y - OAM attributes
;   sprite_x - X coordinate
;
; Output:
;   One sprite written to OAM.
;   OAM cursor advanced by 4 bytes.
;
; Clobbers:
;   A, X, Y
;
; Uses:
;   oam
;   oam_cursor
;   sprite_y
;   sprite_tile
;   sprite_attr
;   sprite_x
;==========================================================================
.proc sprite_draw
	; Save input parameters.
	STA sprite_y
	STX sprite_tile
	STY sprite_attr

	; Get current OAM position.
	LDX oam_cursor

	; Y coordinate (NES OAM uses Y-1).
	LDA sprite_y
	SEC
	SBC #$01
	STA oam,X
	INX

	; CHR tile.
	LDA sprite_tile
	STA oam,X
	INX

	; OAM attributes.
	LDA sprite_attr
	STA oam,X
	INX

	; X coordinate.
	LDA sprite_x
	STA oam,X
	INX

	; Save updated OAM position.
	STX oam_cursor

	RTS
.endproc

;==========================================================================
; Draw a 16x16 metasprite using four 8x8 hardware sprites.
; Each entry contains Y offset, CHR tile, OAM attributes, and X offset.
;
; Input:
;   ptr_lo / ptr_hi - pointer to metasprite data
;   A - Base X position
;   X - Base Y position
;
; Output:
;   Four sprites written to OAM.
;   OAM cursor advanced by 16 bytes.
;
; Clobbers:
;   A, X, Y
;
; Uses:
;   oam
;   oam_cursor
;   ptr_hi
;   ptr_lo
;   metasprite_x
;   metasprite_y
;==========================================================================
.proc sprite_draw_meta
	STA metasprite_x
	STX metasprite_y

	LDY #$00
	LDX oam_cursor

@loop:
	; Calculate Y position (NES OAM Y is offset by -1).
	LDA (ptr_lo),Y
	CLC
	ADC metasprite_y
	SEC
	SBC #$01
	STA oam,X
	INX
	INY

	; Copy CHR tile.
	LDA (ptr_lo),Y
	STA oam,X
	INX
	INY

	; Copy OAM attributes.
	LDA (ptr_lo),Y
	STA oam,X
	INX
	INY

	; Calculate X position.
	LDA (ptr_lo),Y
	CLC
	ADC metasprite_x
	STA oam,X
	INX
	INY

	; Four sprites = 16 bytes.
	CPY #$10
	BNE @loop

	; Save updated OAM position.
	STX oam_cursor

	RTS
.endproc
