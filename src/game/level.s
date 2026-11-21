.include "../core/constants.inc"
.include "level.inc"

.importzp ptr_lo
.importzp ptr_hi
.importzp page_count
.import level_01_map

.export level_load

.segment "CODE"

;==========================================================================
; Load current level into VRAM.
;
; Writes the level map directly to the nametable in VRAM ($2000-$23BF).
;
; Input:
;   None
;
; Output:
;   Nametable written to VRAM.
;
; Clobbers:
;   A, X, Y
;
; Uses:
;   ptr_lo
;   ptr_hi
;   page_count
;
; Requirements:
;   - Rendering disabled or PPU in VBlank.
;   - level_01_map contains exactly 960 tiles.
;==========================================================================
.proc level_load
	; Reset PPU latch
	LDA PPU_STATUS

	; VRAM = $2000
	LDA #$20
	STA PPU_ADDR
	LDA #$00
	STA PPU_ADDR

	; Pointer -> level_01_map
	LDA #<level_01_map
	STA ptr_lo
	LDA #>level_01_map
	STA ptr_hi

	; Three full pages (3 × 256 = 768 bytes)
	LDA #$03
	STA page_count

@page_loop:
	LDY #$00

@page_bytes:
	; Read tile and write to PPU
	LDA (ptr_lo),Y
	STA PPU_DATA

	INY
	BNE @page_bytes

	INC ptr_hi

	DEC page_count
	BNE @page_loop

	; Last 192 bytes
	LDY #$00

@last_chunk:
	LDA (ptr_lo),Y
	STA PPU_DATA

	INY
	CPY #$C0
	BNE @last_chunk

	RTS
.endproc

