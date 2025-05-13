		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table
HEAP_TOP	EQU		0x20001000
HEAP_BOT	EQU		0x20004FE0
MAX_SIZE	EQU		0x00004000		; 16KB = 2^14 bytes	
MIN_SIZE	EQU		0x00000020		; 32B  = 2^5 bytes	
	
MCB_TOP		EQU		0x20006800      ; 2^10 Bytes = 1K Space
MCB_BOT		EQU		0x20006BFE
MCB_ENT_SZ	EQU		0x00000002		; 2 Bytes per entry
MCB_TOTAL	EQU		512				; 2^9 bytes= 512 entries
	
INVALID		EQU		-1				; an invalid id
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Memory Control Block Initialization
		EXPORT	_heap_init
_heap_init
	; Implement by yourself
		; Zeroing the heap space: no need to implement in step 2's assembly code.
		
		; Initialize MCB
		LDR		R0, =MCB_TOP		;R0 = mcb[0] - root | r0 will represent the index of mcb so i
		LDR		R1, =MAX_SIZE		;R1 = max bytes in heap
		STRH	R1, [R0], #0x4		;Set max bytes into root to indicate memory avaliable 
									; Post increment by four to keep the addresses memory aligned in the loop. So the loop starts at .....4 memory
									
		LDR		R2, =MCB_BOT		; Condition
		MOV		R3, #0				; Value to store in the rest of the MCB index
		
		; Traverse the heap memory through the mcb blocks
		; Start at the top and and go to each index until we reach mcb bot
_loop
		CMP		R0, R2				; Current MCB Index >= MCB Bottom
		BGE		_break
		
		; This is incrementing the index of mcb mcb[i] by incrmenting by two memory addresses since each memory address holds two bytes
		STRH 	R3, [R0, #0x2]!			; store 0 into all the other MCB indexes to represnted unused space | MCB index i++
		B		_loop
			
			
_break
		
		MOV		pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory Allocation
; void* _k_alloc( int size )
		EXPORT	_kalloc
_kalloc
	; Implement by yourself
		
		; Save register
		PUSH 	{R4, R11, LR}
		
		; Intitialize the MCB
		LDR		R1, =MCB_TOP	; [R1 = Left]
		LDR		R2, =MCB_BOT	; [R2 = Right]
		LDR		R3, =MCB_ENT_SZ ; [R3 = MCB_ENT_SZ]
		
		;Correct Size if needed
		; If Passed in size is >= 32 bytes continue to ralloc otherwise set minimum size to 32 bytes
		CMP		R0, #32
		BGE		_ralloc		; r0 >=	32
		
_else_condition
		MOV		R0, #32
		
_ralloc	

		; Setting up variables
		; Entire
		ADDS	R4, R1, R3
		SUBS	R4, R2, R4		; [R4 = Entire] = right - left + mcb_ent_sz
		
		; Half
		ASR		R5, R4, #1		; [R5 = Half] = Entire / 2 | This might be incorrect due to ASR double check and if anything use the DIVS instead of ASR
		
		; Midpoint
		ADDS	R6, R1, R5		; [R6 = Midpointer] = left + half
		
		; Heap_addr
		MOV		R7, #0;			; [R7 = Heap_addr] = null
		
		; Act_Entire_Size
		LSL		R8, R4, #4		; [R8 = Act_Entire_Size] = Entire * 16	| This might be incorrect due to LSL. Double check and if anything use the MUL instead of lsl
		
		; Act_Half_Size
		LSL		R9, R5, #4		; [R9 = Act_Half_Size] = Half * 16 | This might be incorrect due to LSL. Double check and if anything use the MUL instead of lsl
		
		
		; Start of space search
		CMP		R0, R9
		BLE		_if_condition1	; If size >= act_half_size go to _if_condition1
		
								; Else
		; Check if space is avaliable by using a condition to check if its occupied
		; If Check code here
								; Else - we have entire space here		
		; Check if space can fit
		; If Check code here
		
								; Else
		; Cant fit return null
		
		
_if_condition1					; if_condition1 = size <= act_half_size
; Might do recursion here
		
; Check if heap_addr == null - means we found a space that couldnt fit on the left side. lets go right

							
;_if>>>_if_condition			; _if>>>_if_condition Check if heap_addr == null = were going right
; Recursive call here to go right

; After recursive call split the parent MCB with another condition



		
		
		
;_else>>>_if_condition			; else>>>if_condition = Checking if space if avaliable


;_else>>>_else>>>_if_condition	; _else>>>_else>>>_if_condition = Checking if size can fit into the avalible space
; If code can fit update the MCB block with the new space and return the actuall heap address

		
		MOV		pc, lr
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory De-allocation
; void free( void *ptr )
		EXPORT	_kfree
_kfree
		CMP     R0, #0                  ; Check for NULL pointer
        BXEQ    LR                      ; Return NULL if ptr is NULL

        PUSH    {R1-R2, LR}            ; Save registers
        LDR     R1, =HEAP_TOP
        LDR     R2, =HEAP_BOT
        CMP     R0, R1                  ; Check if ptr < HEAP_TOP
        BLO     _kfree_fail
        CMP     R0, R2                  ; Check if ptr > HEAP_BOT
        BHI     _kfree_fail

        ; Compute MCB address: mcb_top + (ptr - heap_top) / 16
        SUBS    R0, R0, R1              ; R0 = ptr - heap_top
        LSRS    R0, R0, #4              ; Divide by 16
        LDR     R1, =MCB_TOP
        ADDS    R0, R1, R0              ; R0 = mcb_addr

        BL      _rfree                  ; Call _rfree(mcb_addr)
        CMP     R0, #0                  ; Check if _rfree failed
        BEQ     _kfree_fail

        ; Success: return original ptr (restore from stack)
        POP     {R1-R2, LR}             ; Restore registers
        BX      LR                      ; Return ptr

_kfree_fail
        MOVS    R0, #0                  ; Return NULL
        POP     {R1-R2, LR}
        BX      LR
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Recursive Free Function
; void _rfree(int index)
		EXPORT  _rfree
_rfree
        PUSH    {R4-R7, LR}             ; Save registers

        ; Load MCB contents
        LDRH    R3, [R0]                ; R3 = mcb_contents
        LSRS    R4, R3, #4              ; R4 = mcb_chunk (size in units)
        LSLS    R4, R4, #4              ; R4 = my_size (clears used bit)

        ; Mark as free
        STRH    R4, [R0]                ; Clear used bit in MCB

        ; Calculate mcb_offset and check left/right
        LDR     R1, =MCB_TOP
        SUBS    R5, R0, R1              ; R5 = mcb_offset
        LSRS    R6, R4, #4              ; R6 = mcb_chunk (size in units)
        UDIV    R7, R5, R6              ; R7 = mcb_offset / mcb_chunk
        ANDS    R7, R7, #1              ; R7 % 2
        CMP     R7, #0
        BNE     _rfree_right

        ; Left block case
        ADDS    R6, R0, R6              ; R6 = buddy_addr (mcb_addr + mcb_chunk)
        LDR     R1, =MCB_BOT
        CMP     R6, R2                  ; Check if buddy is beyond MCB_BOT
        BHS     _rfree_done

        LDRH    R3, [R6]                ; R3 = buddy_contents
        TST     R3, #1                  ; Check buddy's used bit
        BNE     _rfree_done

        ; Buddy is free, check size
        LSRS    R7, R3, #4
        LSLS    R7, R7, #4              ; R7 = buddy_size (cleared used bit)
        CMP     R7, R4                  ; Compare with my_size
        BNE     _rfree_done

        ; Merge with buddy
        MOVS    R3, #0
        STRH    R3, [R6]                ; Clear buddy
        LSLS    R4, R4, #1              ; Double size
        STRH    R4, [R0]                ; Update current block
        BL      _rfree                  ; Recurse
        B       _rfree_exit

_rfree_right
        ; Right block case
        LDR     R1, =MCB_TOP
        SUBS    R6, R0, R4              ; R6 = buddy_addr (mcb_addr - chunk_size_in_bytes)
        CMP     R6, R1                  ; Check if buddy is below MCB_TOP
        BLO     _rfree_done

        LDRH    R3, [R6]                ; R3 = buddy_contents
        TST     R3, #1                  ; Check buddy's used bit
        BNE     _rfree_done

        ; Buddy is free, check size
        LSRS    R7, R3, #4
        LSLS    R7, R7, #4              ; R7 = buddy_size (cleared used bit)
        CMP     R7, R4                  ; Compare with my_size
        BNE     _rfree_done

        ; Merge with buddy
        MOVS    R3, #0
        STRH    R3, [R0]                ; Clear current block
        LSLS    R4, R4, #1              ; Double size
        STRH    R4, [R6]                ; Update buddy
        MOV     R0, R6                  ; Set buddy as new mcb_addr
        BL      _rfree                  ; Recurse
        B       _rfree_exit

_rfree_done
        ; Return mcb_addr (success)
        MOV     R0, R0                  ; R0 still holds mcb_addr
_rfree_exit
        POP     {R4-R7, PC}             ; Restore registers and return

		END