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
		LDR 	R0, =SYSTEMCALLTBL		; initialize base system call addr | (address 20007B00)
		
		; initialize timer_start
		LDR		R1, =_timer_start		; retreive timer_start location
		STR		R1, [R0, #4]!			; store timer_start addr at base + 4 |(address 20007B04)
		
		; intialize signal handler
		LDR		R1, =_signal_handler	; retreive _signal_handler location
		STR		R1, [R0, #4]!			; store _signal_handler addr at base + 8 | (address 20007B08)
		
		; SYS_MEMCPY skipped not part of assignment 
		
		; intialize _kalloc
		LDR		R1, =_kalloc			; retreive _kalloc location
		STR		R1, [R0, #8]!			; store kalloc addr at base + 16 | (address 20007B10)
		
		; initialize _kfree
		LDR		R1, =_kfree				; retreive _kfree location
		STR		R1, [R0, #4]!			; store _kfree addr at base + 20 | (address 20007B14)
		
		MOV		pc, lr					; Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table Jump Routine
        EXPORT	_syscall_table_jump
_syscall_table_jump
		PUSH 	{R0, R4-R11, LR}		; Save registers
		
		; Check for valid table jump
		; if(r7 > #5 || r7 < 0 ) return invalid;
		CMP 	R7, #5					
		BGT	  	_invalid				; If R7 > 5	return invalid
		CMP		R7, #0					
		BLT		_invalid				; Or if R7 < 0 return invalid
		
		; Find corresponsing jump address based off passed in R7 value
		; Jump addr = base system call + (Table value * 4)
		LDR		R4, =SYSTEMCALLTBL		; retreive base system call addr
		MOV		R5, #4					
		MUL		R6,	R7, R5				; R6 = Table value * 4
		ADD		R8, R4, R6				; R8 = base system call + (Table value * 4)
		LDR		R9, [R4, R6]			; R9 = jump addr 
		BLX		R9						; Branch to jump addr
		
		MOV		R12, R0					; Save return value from jump addr into R12
		POP		{R0, R4-R11, LR}		; Restore original register
		MOV		R0, R12					; Save return value into R0
		BX		LR						; Return
		
_invalid	
		MOV		pc, lr					; Return
		
		END


		
