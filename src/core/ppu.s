.include "constants.inc"

.import attr_tbl
.import palettes

.export ppu_load_palette
.export ppu_load_attributes

.segment "CODE"

;==========================================================================
; Load the 32-byte palette table into PPU palette memory.
;
; Input:
;   None
;
; Output:
;   PPU palette memory updated.
;
; Clobbers:
;   A, X
;
; Uses:
;   palettes
;==========================================================================
.proc ppu_load_palette
	; reset PPU latch
	LDA PPU_STATUS
	
	; set VRAM address = $3F00
	LDA #$3F
	STA PPU_ADDR
	LDA #$00
	STA PPU_ADDR
	
	LDX #$00

@palette_loop:
	LDA palettes, X
	STA PPU_DATA
	
	INX
	CPX #$20
	BNE @palette_loop
	
	RTS
.endproc

;==========================================================================
; Load the 64-byte attribute table into the PPU nametable.
;
; Input:
;   None
;
; Output:
;   PPU attribute table updated.
;
; Clobbers:
;   A, X
;
; Uses:
;   attr_tbl
;==========================================================================
.proc ppu_load_attributes
	; reset latch
	LDA PPU_STATUS

	; VRAM = $23C0
	LDA #$23
	STA PPU_ADDR
	LDA #$C0
	STA PPU_ADDR

	LDX #$00

@attr_loop:
	LDA attr_tbl, X
	STA PPU_DATA

	INX
	CPX #$40
	BNE @attr_loop

	RTS
.endproc
