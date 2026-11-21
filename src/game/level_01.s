.include "objects.inc"
.include "level.inc"

;==========================================================================
; Level 01 (Example)
;==========================================================================
.segment "RODATA"

.export level_01_map
.export level_01_objects_x
.export level_01_objects_y
.export level_01_objects_type

level_01_objects_x:
	.byte $20, $A0, $E8, $60
level_01_objects_x_end:

level_01_objects_y:
	.byte $40, $90, $80, $B0
level_01_objects_y_end:

level_01_objects_type:
	.byte OBJECT_TYPE_TREASURE
	.byte OBJECT_TYPE_TREASURE
	.byte OBJECT_TYPE_TREASURE
	.byte OBJECT_TYPE_TREASURE
level_01_objects_type_end:

;--------------------------------------------------------------------------
; Compile-time checks >>>
;--------------------------------------------------------------------------

OBJ_X_COUNT   = level_01_objects_x_end - level_01_objects_x
OBJ_Y_COUNT   = level_01_objects_y_end - level_01_objects_y
OBJ_TYP_COUNT = level_01_objects_type_end - level_01_objects_type

.assert OBJ_X_COUNT <= OBJECT_POOL_SIZE, error, "Too many objects in level 01"
.assert OBJ_Y_COUNT <= OBJECT_POOL_SIZE, error, "Too many objects in level 01"
.assert OBJ_TYP_COUNT = OBJ_Y_COUNT, error, "Object type table size mismatch"

;--------------------------------------------------------------------------
; <<<
;--------------------------------------------------------------------------

level_01_map:
.include "level_01.inc"
level_01_map_end:

;--------------------------------------------------------------------------
; Compile-time checks >>>
;--------------------------------------------------------------------------

LEVEL_MAP_SIZE = (level_01_map_end - level_01_map)
.assert LEVEL_MAP_SIZE = 960, error, "Level map must be exactly 960 bytes"

;--------------------------------------------------------------------------
; <<<
;--------------------------------------------------------------------------

