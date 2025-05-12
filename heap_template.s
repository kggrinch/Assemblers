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