		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table
SYSTEMCALLTBL	EQU		0x20007B00 ; originally 0x20007500
	
SYS_EXIT		EQU		0x0		; address 20007B00
SYS_ALARM		EQU		0x1		; address 20007B04
SYS_SIGNAL		EQU		0x2		; address 20007B08
SYS_MEMCPY		EQU		0x3		; address 20007B0C
SYS_MALLOC		EQU		0x4		; address 20007B10
SYS_FREE		EQU		0x5		; address 20007B14

; Importing the addresses of the routines. Instruction from Final_project_pdf page 5
	IMPORT _kfree 
	IMPORT _kalloc 
	IMPORT _signal_handler 
	IMPORT _timer_start 
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table Initialization
		EXPORT	_syscall_table_init
_syscall_table_init
	; Implement by yourself
		LDR 	R0, =SYSTEMCALLTBL
		
		;MOV		R1, =0
		;STR		R1, [R0], #4
		
		LDR		R1, =_timer_start
		STR		R1, [R0, #4]!
		
		LDR		R1, =_signal_handler
		STR		R1, [R0, #4]!
		
		;MOV		R1, =0
		;STR		R1, [R0], #4
		
		LDR		R1, =_kalloc
		STR		R1, [R0, #8]!
		
		LDR		R1, =_kfree
		STR		R1, [R0, #4]!
		
		MOV		pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table Jump Routine
        EXPORT	_syscall_table_jump
_syscall_table_jump
	;; Implement by yourself
		CMP 	R7, #5	; Might not need to compare for validness
		BHI	  	_invalid
		LDR		R0, =SYSTEMCALLTBL
		LSL		R1, R7, #2
		ADD		R2, R0, R1
		LDR		PC, [R0, R1]
_invalid	
		MOV		pc, lr			

		END


		
