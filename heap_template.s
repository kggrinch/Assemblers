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
	;; Implement by yourself
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
	;; Implement by yourself
		MOV		pc, lr
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory De-allocation
; void free( void *ptr )
		EXPORT	_kfree
_kfree
	;; Implement by yourself
		MOV		pc, lr					; return from rfree( )
		
		END
