;==========================================================================
; 6502 Zero Page Memory (256 bytes $00-$FF)
;==========================================================================
.segment "ZEROPAGE"


.exportzp ptr_lo
.exportzp ptr_hi
.exportzp scratch00
.exportzp scratch01
.exportzp page_count

; Generic pointers
ptr_lo:     .res 1
ptr_hi:     .res 1

; Scratch (change variables when needed)
scratch00:  .res 1
scratch01:  .res 1

; Loading level vars
page_count: .res 1

; Check total Zero Page allocation across all modules.
.import __ZEROPAGE_SIZE__: absolute
.assert __ZEROPAGE_SIZE__ <= $100, lderror, "Zero Page exceeds 256 bytes"
