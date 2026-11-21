.segment "HEADER"

;==========================================================================
; Define NES cartridge Header
;==========================================================================
INES_MAPPER = 0 ; 0 = NROM
INES_MIRROR = 0 ; 0 = horizontal mirroring, 1 = vertical mirroring
INES_SRAM   = 0 ; 1 = battery backed SRAM at $6000-7FFF

header_bytes:
	.byte $4E, $45, $53, $1A             ; 'N', 'E', 'S', $1A
	.byte $02                            ; 16k PRG bank count ; 16k * 2
	.byte $01                            ; 8k CHR bank count
	.byte INES_MIRROR | (INES_SRAM << 1) | ((INES_MAPPER & $0f) << 4)
	.byte (INES_MAPPER & %11110000)
	.byte $00, $00, $00, $00, $00, $00, $00, $00 ; padding filled with zeroes
header_bytes_end:

;--------------------------------------------------------------------------
; Compile-time checks >>>
;--------------------------------------------------------------------------

.assert (header_bytes_end - header_bytes) = 16, error, "NES header should be 16 bytes"

; Check correctness of NES header values
.assert INES_MAPPER >= 0, error, "Invalid mapper number"
.assert INES_MAPPER <= $FF, error, "Mapper number exceeds 8-bit range"

.assert INES_MIRROR = 0 .or INES_MIRROR = 1, error, "Invalid mirroring mode"
.assert INES_SRAM = 0 .or INES_SRAM = 1, error, "Invalid SRAM configuration"

;--------------------------------------------------------------------------
; <<<
;--------------------------------------------------------------------------

