OBJECT_POOL_SIZE = 8
OBJECT_ACTIVE    = 1
OBJECT_INACTIVE  = 0

;==========================================================================
; Define objects constants and configurations
;==========================================================================

; Object types, indices must match object dimension tables.
;
; Type ID   Width   Height
; 0         8       8
; 1         16      16
; 2         16      24
; 3         24      16
; 4         24      24
; 5         32      16
; 6         32      24
; 7         32      24
; etc.
OBJECT_TYPE_TREASURE = 0
OBJECT_TYPE_LIFE     = 1

;==========================================================================
; Object indexes in CHR
;==========================================================================

TILE_TREASURE = $34
TILE_LIFE     = $42

