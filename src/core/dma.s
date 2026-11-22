.include "../core/constants.inc"
.include "../gfx/gfx.inc"

.import oam

.export dma_transfer

.segment "CODE"

;==========================================================================
; Copy the OAM shadow buffer to PPU OAM using DMA during VBlank.
;
; Input:
;   None
;
; Output:
;   PPU OAM updated from the OAM shadow buffer.
;
; Clobbers:
;   A
;
; Uses:
;   oam
;==========================================================================
.proc dma_transfer
	LDA #$00
	STA PPU_OAM_ADDR

	LDA #>oam
	STA OAM_DMA
	RTS
.endproc
