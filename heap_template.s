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
		STR		R1, [R0], #0x4		;Set max bytes into root to indicate memory avaliable 
									;Post increment by four to keep the addresses memory aligned in the loop. So the loop starts at .....4 memory
									
		LDR		R2, =MCB_BOT		; Condition
		MOV		R3, #0				; Value to store in the rest of the MCB index
		
		; Traverse the heap memory through the mcb blocks
		; Start at the top and and go to each index until we reach mcb bot
_loop
		CMP		R0, R2				; Current MCB Index >= MCB Bottom
		BGE		_break
		
		; This is incrementing the index of mcb mcb[i] by incrmenting by two memory addresses since each memory address holds two bytes
		STR 	R3, [R0], #0x4		; store 0 into all the other MCB indexes to represnted unused space | MCB index i++
		B		_loop
			
			
_break
		
		MOV		pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory Allocation
; void* _k_alloc( int size )
		EXPORT	_kalloc
_kalloc
	; Implement by yourself
		
						
		PUSH 	{R4-R11, LR}	; Save called in registers
		
		; Intitialize the MCB
		LDR		R1, =MCB_TOP	; [R1 = Left]
		LDR		R2, =MCB_BOT	; [R2 = Right]
		
								
		CMP		R0, #32			; Check if passed in size is valid. If not give it the minimum size
		BLT		_minimum_size
		B		_recursive_branch
		
_minimum_size
		MOV		R0, #32
		
_recursive_branch	
		BL		_ralloc
		POP		{R4-R11, LR}			; Restore and return
		MOV		PC, LR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Recursive Malloc Memory Allocation Function
; void* _r_alloc(int size, int left, int right)
_ralloc	
		
		PUSH 	{R4-R11, LR}			; Save register and link register
		
		; Setting up variables						

		LDR		R9, =MCB_ENT_SZ			;[R3 = Entire] = right - left + mcb_ent_sz
		SUBS	R3, R2, R1				;R3 = right - left
		ADDS	R3, R3, R9	 			;R3 = (right - left) + mcb_ent_sz	
		
		MOV		R9, #1
		ASR		R4, R3, #1				;[R4 = Half] = Entire / 2 | This might be incorrect due to ASR double check and if anything use the DIVS instead of ASR
		
		ADDS	R5, R1, R4				;[R5 = Midpointer] = left + half
		
		MOV		R6, #0;					;[R6 = Heap_addr] = null
		
		MOV		R9, #16
		MUL		R7, R3, R9				;[R7 = Act_Entire_Size] = Entire * 16	| This might be incorrect due to LSL. Double check and if anything use the MUL instead of lsl
		
		MUL		R8, R4, R9				;[R8 = Act_Half_Size] = Half * 16 | This might be incorrect due to LSL. Double check and if anything use the MUL instead of lsl
		
		
										; Start of memory space search
		CMP		R0, R8
		BGT		_else					; If size <= act_half_size go to _if
		
		; _if - recursive call left
										
		; heap_addr = _ralloc( size, left, midpoint - mcb_ent_sz );
		MOV		R0, R0					; leave size unchanged
		MOV		R1, R1					; leave left unchanged
		PUSH	{R2}					; Save original right
		PUSH	{R0}
		LDR		R9, =MCB_ENT_SZ
		SUBS	R2, R5, R9				; midpoint - mcb_ent_sz
		BL		_ralloc	
		MOV		R6, R0					; Store heap address to heap_add variable r6
		POP		{R0}					; Retore original r0 argument (size)
		POP		{R2}					; Restore original right)
		CMP		R6, #0					; R0 contains the heap_addr | If R0 != null return, Otherwise go right | Original R0 is lost because we are holding the return ptr
		BNE		_split_parent
		
										; Go Right
		; return _ralloc( size, midpoint, right);	
		
		MOV		R0, R0					; leave size unchanged
		PUSH	{R1}					; save original left
		PUSH	{R0}					; save original r0 size argument
		MOV		R1, R5					; left = midpoint
		MOV		R2, R2					; leave right unchanged
		BL		_ralloc
		MOV		R6, R0					; Save returned heap address into heap_addr variable r6
		POP		{R0}					; Restore original r0 size
		POP		{R1}					; Restore original right
		CMP		R6, #0					; R6 contains the heap_addr | R6 != null then split parent and return heap_addr, Otherwise return null heap is full
		BEQ		_ralloc_return			
		
		B		_split_parent			
		

_else	; Try allocating entire space

		; New
		;PUSH	{R0}			; Save original r0
		;BL		_m2a			; branch
		;MOV		R9, R0			; move result into r9
		;POP		{R0}			; restore original r0
		;LDR		R10, [R9]		; access value at r9
		;AND		R11, R10, #0x01



		; Original
		LDR 	R9, [R1]		; R9 = mcb[left]
		AND		R10, R9, #0x01	; r9 was r2
		CMP		R10, #0
		BNE		_return_null	; If mcb[left] != 0 memory space used return null. Otherwise, we have an entire space
		
		; We have an entire space
		CMP		R9, R7			
		BLT		_return_null	; If mcb[left] < act_entire_size cant fit return null. Otherwise, compute heap address
		
		; Convert memory spot to occupied
		ORR		R10, R7, #0x01	; change bit sign to indicate space is now used
		STR		R10, [R1]		; insert changed bit into mcb block
		
		; Compute the corresponding heap address R0 = heap_top + ( left - mcb_top ) * 16 
		; Might be computing the corresponding heap address incorrectly
		LDR		R10, =HEAP_TOP
		LDR		R11, =MCB_TOP
		MOV		R12, #16
		SUBS	R6, R1, R11			; R6(heap_address) = left - mcb_top
		MUL		R6, R6, R12			; R6(heap_address) = (left - mcb_top) * 16
		ADDS	R6, R6, R10			;  R6(heap_address) = ((left - mcb_top) * 16) + heap_top 
		B		_ralloc_return


_split_parent

		; Adding new here
		;MOV		R1, R5
		;BL		_m2a
		;LDR		R2, [R0]
		;AND		R2, R2, #0x01
		;CMP		R2, #0			; If MCB[midpoint] != 0 - parent already split _ralloc_return, Otherwise split the parent
		;BNE		_ralloc_return
		
		;MOV		R2, R7
		;STR		R2, [R0]
		;B		_ralloc_return	
		
		; Original
		LDR		R9, [R5]		;Load data from midpoint
		AND		R10, R9, #0x01		
		CMP		R10, #0			; If MCB[midpoint] != 0 - parent already split _ralloc_return, Otherwise split the parent
		BNE		_ralloc_return
		
		;else
		STR		R8, [R5]		; Store act_half_size into mcb[midpoint] | Was r9 but changed to r5 because we need to store the value into the mcb[midpoint]
		B	_ralloc_return	
	
_return_null
		MOV		R6, #0				; Set return register to null

_ralloc_return
		MOV		R0, R6				; Store the heap address into r0
		POP     {R4-R11, LR}		; Restore registers
		MOV		PC, LR				; Return
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory De-allocation
; void free( void *ptr )
		EXPORT	_kfree
_kfree
		PUSH    {R1-R2, LR}            ; Save registers
		
		CMP     R0, #0                  ; Check for NULL pointer
		BEQ		_kfree_fail				; Return NULL if ptr is NULL

        ;PUSH    {R1-R2, LR}            ; Save registers Need to delete since I am saving the registers above
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
        LDR    	R3, [R0]           		; R3 = mcb_contents | Changed from LDRH to LDR
        LSRS    R4, R3, #4              ; R4 = mcb_chunk (size in units) | Might change to DIV
        LSLS    R4, R4, #4              ; R4 = my_size (clears used bit) | Might change to MUL

        ; Mark as free
        STR    R4, [R0]                ; Clear used bit in MCB | Check if cleared correctly | Changed from STRH to STR

        ; Calculate mcb_offset and check left/right
        LDR     R1, =MCB_TOP
        SUBS    R5, R0, R1              ; R5 = mcb_offset
        LSRS    R6, R4, #4              ; R6 = mcb_chunk (size in units)
        UDIV    R7, R5, R6              ; R7 = mcb_offset / mcb_chunk
        AND    	R7, R7, #1              ; R7 % 2
        CMP     R7, #0
        BNE     _rfree_right

        ; Left block case
        ADDS    R6, R0, R6              ; R6 = buddy_addr (mcb_addr + mcb_chunk)
        LDR     R1, =MCB_BOT
        CMP     R6, R1                  ; Check if buddy is beyond MCB_BOT | Issue here Changed R2 with R1
        BHS     _rfree_done

        LDR     R3, [R6]                ; R3 = buddy_contents | Changed from LDRH to LDR
        TST     R3, #1                  ; Check buddy's used bit
        BNE     _rfree_done

        ; Buddy is free, check size
        LSRS    R7, R3, #4
        LSLS    R7, R7, #4              ; R7 = buddy_size (cleared used bit)
        CMP     R7, R4                  ; Compare with my_size
        BNE     _rfree_done

        ; Merge with buddy
        MOVS    R3, #0
        STR    	R3, [R6]                ; Clear buddy | Changed from STRH to STR
        LSLS    R4, R4, #1              ; Double size
        STR    	R4, [R0]                ; Update current block | Changed from STRH to STR
        BL      _rfree                  ; Recurse
        B       _rfree_exit

_rfree_right
        ; Right block case
        LDR     R1, =MCB_TOP
        SUBS    R6, R0, R6              ; R6 = buddy_addr (mcb_addr - mcb_chunk) | Issue here incorrect buddy address | Change R4 to R6 when subtracting from
        CMP     R6, R1                  ; Check if buddy is below MCB_TOP
        BLO     _rfree_done

        LDR    	R3, [R6]                ; R3 = buddy_contents | Changed from LDRH to LDR
        TST     R3, #1                  ; Check buddy's used bit
        BNE     _rfree_done

        ; Buddy is free, check size
        LSRS    R7, R3, #4
        LSLS    R7, R7, #4              ; R7 = buddy_size (cleared used bit)
        CMP     R7, R4                  ; Compare with my_size
        BNE     _rfree_done

        ; Merge with buddy
        MOVS    R3, #0
        STR    	R3, [R0]                ; Clear current block | Changed from STRH to STR
        LSLS    R4, R4, #1              ; Double size
        STR    	R4, [R6]                ; Update buddy | Changed from STRH to STR
        MOV     R0, R6                  ; Set buddy as new mcb_addr
        BL      _rfree                  ; Recurse
        B       _rfree_exit

_rfree_done
        ; Return mcb_addr (success)
        MOV     R0, R0                  ; R0 still holds mcb_addr
_rfree_exit
        POP     {R4-R7, LR}             ; Restore registers and return
		BX		LR

		END