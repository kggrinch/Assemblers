		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table
HEAP_TOP	EQU		0x20001000
HEAP_BOT	EQU		0x20004FE0
MAX_SIZE	EQU		0x00004000		; 16KB = 2^14
MIN_SIZE	EQU		0x00000020		; 32B  = 2^5
	
MCB_TOP		EQU		0x20006800      	; 2^10B = 1K Space
MCB_BOT		EQU		0x20006BFE
MCB_ENT_SZ	EQU		0x00000002		; 2B per entry
MCB_TOTAL	EQU		512			; 2^9 = 512 entries
	
INVALID		EQU		-1			; an invalid id
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Memory Control Block Initialization
		EXPORT	_heap_init
_heap_init
	;; Implement by yourself
	
		MOV		pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory Allocation
; void* _k_alloc( int size )
		EXPORT	_kalloc
_kalloc
	;; Implement by yourself
		MOV		pc, lr
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory De-allocation
; void free( void *ptr )
		EXPORT	_kfree
_kfree
		CMP     R0, #0              ; Check for NULL pointer
        BXEQ    LR                  ; If NULL, return immediately
        
        PUSH    {R0-R1, LR}
        LDR     R1, =HEAP_TOP
        SUBS    R0, R0, R1          ; R0 = offset from heap start
        CMP     R0, #MAX_SIZE       ; Validate pointer is within heap
        BHS     _kfree_invalid      ; If out of bounds, skip
        LSRS    R0, R0, #5          ; Divide by 32 (MIN_SIZE)
        BL      _rfree
_kfree_invalid
        POP     {R0-R1, LR}
        BX      LR
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Recursive Free Function
; void _rfree(int index)
_rfree
        PUSH    {R0-R7, LR}

        ; Calculate MCB address
        LDR     R1, =MCB_TOP
        LSLS    R2, R0, #1          ; index * 2
        ADDS    R1, R1, R2          ; R1 = &mcb[index]

        ; Get current block info
        LDRH    R3, [R1]            ; R3 = mcb[index]
        LSRS    R4, R3, #4          ; R4 = size in 32B units
        LSLS    R4, R4, #4          ; R4 = size in original bits
        BICS    R3, R3, #1          ; Clear in-use bit
        STRH    R3, [R1]            ; Mark as free

        ; Find buddy (index ^ size_in_blocks)
        LSRS    R5, R4, #4          ; R5 = size in blocks
        EORS    R6, R0, R5          ; R6 = buddy index

        ; Validate buddy index
        CMP     R6, #MCB_TOTAL
        BHS     _free_done          ; Use BHS instead of BGE for unsigned

        ; Check buddy compatibility
        LSLS    R2, R6, #1
        LDR     R7, =MCB_TOP
        ADDS    R7, R7, R2          ; R7 = &mcb[buddy]
        LDRH    R2, [R7]            ; R2 = buddy entry
        
        LSRS    R3, R2, #4
        LSLS    R3, R3, #4          ; R3 = buddy's size bits
        CMP     R3, R4              ; Same size?
        BNE     _free_done
        TST     R2, #1              ; Buddy free?
        BNE     _free_done

        ; Merge blocks
        MOVS    R3, #0
        STRH    R3, [R1]            ; Clear current
        STRH    R3, [R7]            ; Clear buddy

        ; Parent is min(index, buddy)
        CMP     R0, R6
        ITE     LT
        MOVLT   R0, R0
        MOVGE   R0, R6

        ; Set parent size (size*2 + 1)
        LSLS    R4, R4, #1          ; Double size
        ADDS    R4, R4, #1          ; Mark as used
        LSLS    R2, R0, #1
        LDR     R1, =MCB_TOP
        ADDS    R1, R1, R2
        STRH    R4, [R1]

        ; Recurse
        BL      _rfree

_free_done
        POP     {R0-R7, LR}
        BX      LR	

		END