.include "objects.inc"
.include "include/macros.inc"
.include "gfx/gfx.inc"

.export objects_pool_init
.export objects_pool_clear
.export objects_draw
.export objects_level_spawn

.importzp ptr_lo
.importzp ptr_hi
.importzp sprite_x
.import sprite_draw
.import sprite_draw_meta
.import level_01_objects_x
.import level_01_objects_y
.import level_01_objects_type
.import level_01_objects_type_end

;--------------------------------------------------------------------------
; Linker-time checks >>>
;--------------------------------------------------------------------------

.assert (level_01_objects_type_end - level_01_objects_type) <= $FF, lderror, "Level 01 object table exceeds 255 entries"

;--------------------------------------------------------------------------
; Linker-time checks >>>
;--------------------------------------------------------------------------

.segment "BSS"

sprite_tile_tmp: .res 1

.segment "ZEROPAGE"

object_level_idx: .res 1
object_level_cnt: .res 1
object_draw_idx:  .res 1

.segment "RODATA"

; Object dimensions are stored in lookup tables indexed by object type.
; Alternatively, width and height can be stored directly in each object
; instance, at the cost of 2 additional bytes of RAM per object.
; Example:
;  - object_x: .res OBJECT_POOL_SIZE
;  - object_y: .res OBJECT_POOL_SIZE
object_width_tbl:
	.byte 8, 16 ;, 16, 24, 24, 32
object_width_tbl_end:

object_height_tbl:
	.byte 8, 16 ; , 24, 16, 24, 16
object_height_tbl_end:

object_tile_tbl:
	.byte TILE_TREASURE
	.byte TILE_LIFE
object_tile_tbl_end:

object_life_metasprite:
	.byte 0, $42, PALETTE_1, 0
	.byte 0, $43, PALETTE_1, 8
	.byte 8, $52, PALETTE_1, 0
	.byte 8, $53, PALETTE_1, 8

;--------------------------------------------------------------------------
; Compile-time checks >>>
;--------------------------------------------------------------------------

OBJ_WIDTH_CNT  = object_width_tbl_end - object_width_tbl
OBJ_HEIGHT_CNT = object_height_tbl_end - object_height_tbl
OBJ_TILE_CNT   = object_tile_tbl_end - object_tile_tbl

.assert OBJ_WIDTH_CNT = OBJ_HEIGHT_CNT, error, "Object width and height tables differ in size"
.assert OBJ_WIDTH_CNT = OBJ_TILE_CNT, error, "Object width and tile tables differ in size"

.assert OBJ_WIDTH_CNT <= OBJECT_POOL_SIZE, error, "Object width table exceeds object pool capacity"
.assert OBJ_HEIGHT_CNT <= OBJECT_POOL_SIZE, error, "Object height table exceeds object pool capacity"
.assert OBJ_TILE_CNT <= OBJECT_POOL_SIZE, error, "Object tile table exceeds object pool capacity"

;--------------------------------------------------------------------------
; <<<
;--------------------------------------------------------------------------

.segment "BSS"

; Array index corresponds to the object slot ID. For example, object_x + 3
; contains the X coordinate of the object in slot 3.
object_active: .res OBJECT_POOL_SIZE
object_type:   .res OBJECT_POOL_SIZE
object_x:      .res OBJECT_POOL_SIZE
object_y:      .res OBJECT_POOL_SIZE

.segment "CODE"

;==========================================================================
; Mark every object slot as inactive.
;
; Input:
;   None
;
; Output:
;   Initialized object pool.
;
; Clobbers:
;   A, X
;
; Uses:
;   object_active
;==========================================================================
.proc objects_pool_init
	LDX #OBJECT_POOL_SIZE - 1

@loop:
	LDA #OBJECT_INACTIVE
	STA object_active, X

	DEX
	BPL @loop

	RTS
.endproc

;==========================================================================
; Find and activate the first free slot in the object pool.
;
; Input:
;   None
;
; Output:
;   X - Index of the free slot or $FF if the pool is full.
;
; Clobbers:
;   A, X
;
; Uses:
;   object_active
;==========================================================================
.proc object_spawn
	LDX #$00 ; index of objects array

@find_slot:
	LDA object_active, X
	BEQ @found

	INX
	CPX #OBJECT_POOL_SIZE
	BNE @find_slot

	; No free slot, return $FF
	LDX #$FF
	RTS

@found:
	LDA #OBJECT_ACTIVE
	STA object_active, X

	RTS
.endproc

;==========================================================================
; Spawn the objects defined for the current level.
;
; Input:
;   None
;
; Output:
;   Level objects added to available pool slots.
;
; Clobbers:
;   A, X, Y
;
; Uses:
;   object_level_idx
;   object_level_cnt
;   level_01_objects_type
;   level_01_objects_x
;   level_01_objects_y
;   object_active
;   object_type
;   object_x
;   object_y
;==========================================================================
.proc objects_level_spawn
	; The table size is calculated from imported symbols at link time.
	; '<' forces the expression to be byte-sized for the immediate operand.
	LDA #<(level_01_objects_type_end - level_01_objects_type)
	STA object_level_cnt
	LDY #$00

@loop:
	CPY object_level_cnt
	BEQ @done

	STY object_level_idx

	; Allocate object slot.
	JSR object_spawn

	; Object pool is full.
	CPX #$FF
	BEQ @next

	; Set object type.
	LDY object_level_idx
	LDA level_01_objects_type, Y
	JSR object_set_type

	; Set object X coordinate.
	LDY object_level_idx
	LDA level_01_objects_x, Y
	JSR object_set_x

	; Set object Y coordinate.
	LDY object_level_idx
	LDA level_01_objects_y, Y
	JSR object_set_y

@next:
	LDY object_level_idx
	INY
	JMP @loop

@done:
	RTS
.endproc

;==========================================================================
; Mark the specified object slot as inactive.
;
; Input:
;   X - Object slot ID
;
; Output:
;   Object marked as inactive. If index is invalid carry is set, otherwise
;	no carry flag.
;
; Clobbers:
;   A
;
; Uses:
;   object_active
;==========================================================================
.proc object_despawn
	CPX #OBJECT_POOL_SIZE
	BCS @invalid_idx

	LDA #OBJECT_INACTIVE
	STA object_active, X

	CLC
	RTS
@invalid_idx:
	SEC
	RTS
.endproc

;==========================================================================
; Clear all arrays in the object pool.
;
; Input:
;   None
;
; Output:
;   All object pool arrays set to zero.
;
; Clobbers:
;   A, X
;
; Uses:
;   object_active
;   object_type
;   object_x
;   object_y
;==========================================================================
.proc objects_pool_clear
	LDX #OBJECT_POOL_SIZE - 1
	LDA #$00 ; all values reset to zeroes

@loop:
	STA object_active, X
	STA object_type, X
	STA object_x, X
	STA object_y, X
	
	DEX
	BPL @loop

	RTS
.endproc

;==========================================================================
; Set an object's X coordinate.
;
; Input:
;   A - X coordinate
;   X - Object ID (slot index)
;
; Output:
;   C - 0: Success
;	   1: Invalid Object ID
;
; Clobbers:
;   None
;
; Uses:
;   object_x
;==========================================================================
.proc object_set_x
	CPX #OBJECT_POOL_SIZE
	BCS @invalid_id

	STA object_x, X

	CLC
	RTS

@invalid_id:
	DEBUG_BREAK
	SEC
	RTS
.endproc

;==========================================================================
; Set an object's type.
;
; Input:
;   A - Object type index
;   X - Object ID (slot index)
;
; Output:
;   C - 0: Success
;   C - 1: Invalid Object ID
;
; Clobbers:
;   None
;
; Uses:
;   object_type
;==========================================================================
.proc object_set_type
	CPX #OBJECT_POOL_SIZE
	BCS @invalid_id

	STA object_type, X

	CLC
	RTS

@invalid_id:
	DEBUG_BREAK
	SEC
	RTS
.endproc

;==========================================================================
; Set an object's Y coordinate.
;
; Input:
;   A - Y coordinate
;   X - Object ID (slot index)
;
; Output:
;   C - 0: Success
;   C - 1: Invalid Object ID
;
; Clobbers:
;   None
;
; Uses:
;   object_y
;==========================================================================
.proc object_set_y
	CPX #OBJECT_POOL_SIZE
	BCS @invalid_id

	STA object_y, X

	CLC
	RTS

@invalid_id:
	DEBUG_BREAK
	SEC
	RTS
.endproc

;==========================================================================
; Get an object's width from its type.
;
; Input:
;   X - Object index
;
; Output:
;   A - Object width or height
;   Y - Object type index
;
; Clobbers:
;   A, Y
;
; Uses:
;   object_type
;   object_width_tbl
;   object_height_tbl
;==========================================================================
; Get an object's height from its type.
.proc object_get_width
	LDA object_type, X
	TAY
	LDA object_width_tbl, Y
	RTS
.endproc

;
; Input:
;   X - Object index
;
; Output:
;   A - Object height
;   Y - Object type index
;
; Clobbers:
;   A, Y
;
; Uses:
;   object_type
;   object_height_tbl
;==========================================================================
.proc object_get_height
	LDA object_type, X
	TAY
	LDA object_height_tbl, Y
	RTS
.endproc

;==========================================================================
; Draw all active supported objects in the object pool.
;
; Supports 8x8 objects and the life metasprite.
;
; Input:
;   None
;
; Output:
;   Active supported objects written to OAM.
;
; Clobbers:
;   A, X, Y
;
; Uses:
;   object_active
;   object_type
;   object_x
;   object_y
;   object_draw_idx
;   sprite_tile_tmp
;   ptr_lo
;   ptr_hi
;   sprite_x
;==========================================================================
.proc objects_draw
	LDX #$00

@loop:
	; Save current object slot ID.
	STX object_draw_idx

	; Check whether object is active.
	LDA object_active, X
	BEQ @next

	; Get object type.
	LDA object_type, X

	CMP #OBJECT_TYPE_TREASURE
	BEQ @treasure

	CMP #OBJECT_TYPE_LIFE
	BEQ @life

	JMP @next

@treasure:
	; Get object tile
	TAX
	LDA object_tile_tbl, X
	STA sprite_tile_tmp

	; Get object X coordinate
	LDY object_draw_idx
	LDA object_x, Y
	STA sprite_x

	; Get object Y coordinate
	LDA object_y, Y

	; Tile
	LDX sprite_tile_tmp

	; Attributes
	LDY #PALETTE_1

	; Draw sprite
	JSR sprite_draw

	JMP @next

@life:
	; Load metasprite pointer
	LDA #<object_life_metasprite
	STA ptr_lo

	LDA #>object_life_metasprite
	STA ptr_hi
	
	; Pass object coordinates
	LDY object_draw_idx
	LDA object_x, Y
	LDX object_y, Y

	JSR sprite_draw_meta

	JMP @next

@next:
	; Restore object slot ID.
	LDX object_draw_idx
	INX
	CPX #OBJECT_POOL_SIZE
	BNE @loop

@done:
	RTS
.endproc
