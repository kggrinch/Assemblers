		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void _bzero( void *s, int n ) : Given a start address it zeros out the n bytes from the start address
; Parameters
;	s 		- pointer to the memory location to zero-initialize
;	n		- a number of bytes to zero-initialize
; Return value
;   none
		EXPORT	_bzero
_bzero
		; implement your complete logic, including stack operations
		;Push	PSP! {LR}	; Push return register into stack | Might not need if not moving to other locations
		;R0 = s
		;R1 = n
		
		MOV			R2, #0		; Counter
		MOV			R3, #0
		
		; Save the start address 
		; Use a loop and store 0s in the memory location at the start address storing 1 byte at a time
		; After each store of a byte incrementd the loop until we have stored up to n bytes
_bzero_loop
		
		CMP		R2, R1			; Check if r2 >= n break
		BGE		_exit
		STRB	R3, [R0], #1	; Clear 1 byte at memory and increment memory location to next memory
		ADDS	R2, R2, #1	; increment counter
		B		_bzero_loop
		
_exit		
		
		MOV		pc, lr	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; char* _strncpy( char* dest, char* src, int size )
; Parameters
;   	dest 	- pointer to the buffer to copy to
;	src	- pointer to the zero-terminated string to copy from
;	size	- a total of n bytes
; Return value
;   dest
		EXPORT	_strncpy
_strncpy
		; implement your complete logic, including stack operations (Artem)
		; Save registers
		PUSH {R4-R5}
		
		; Initialize pointers and counter
		MOV R3, R0	; Save orginial dest for return
		MOV R4, R1  ; src pointer
		MOV R5, R2	; Size counter
		
copy_loop
		; Check if size == 0
		CMP R5, #0
		BEQ done
		
		; Load byte from src and increment
		LDRB R2, [R4], #1
		
		; Check for null terminator
		CMP R2, #0
		BEQ null_found
		
		; Store byte to dest and increment
		STRB R2, [R0], #1
		
		; Decerement size and loop
		SUBS R5, R5, #1
		B copy_loop
		
null_found
		; Padd remaining bytes with null
		MOV R2, #0
		
pad_loop
		CMP R5, #0
		BEQ done
		STRB R2, [R0], #1
		SUBS R5, R5, #1
		B pad_loop
		
done
		; Restore registers and return orginal dest
		MOV R0, R3
		POP {R4-R5}
		BX LR
		
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void* _malloc( int size )
; Parameters
;	size	- #bytes to allocate
; Return value
;   	void*	a pointer to the allocated space
		EXPORT	_malloc
_malloc
		; save registers
		;MOV	 R4, R0	; save argument
		PUSH {R4-R11} ;may need to change
		; set the system call # to R7
		
		; Artems Changes
			MOV R7, #4			; SVC number for malloc
	        SVC     #0x0		; Invoke supervisor call
			MOV		R0, R4
			POP 	{R4-R11} 	; Restore original registers | may need to change
			BX LR
		; Artems Changes	
		
		; resume registers
		;MOV		pc, lr (Artem - I Commented this out)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void _free( void* addr )
; Parameters
;	size	- the address of a space to deallocate
; Return value
;   	none
		EXPORT	_free
_free
		; save registers
		PUSH {R4-R11} ;may need to change
		; set the system call # to R7
		
		; Artems Changes
			MOV R7, #5		; SVC number for free
        	SVC     #0x0
			MOV		R0, R4
			POP 	{R4-R11} 	; Restore original registers | may need to change
			BX LR				; Return					
		; Artems Changes	
			
		; resume registers
		;MOV		pc, lr (Artem - I Commented this out)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; unsigned int _alarm( unsigned int seconds )
; Parameters
;   seconds - seconds when a SIGALRM signal should be delivered to the calling program	
; Return value
;   unsigned int - the number of seconds remaining until any previously scheduled alarm
;                  was due to be delivered, or zero if there was no previously schedul-
;                  ed alarm. 
		EXPORT	_alarm
_alarm
		; save registers
		PUSH {R4-R11} ;may need to change
		; set the system call # to R7
		
		; Artems Changes
			MOV R7, #1		; SVC number for alarm
        	SVC     #0x0	
			MOV R0, #0		; Return 0
			POP {R4-R11} 	;may need to change
			BX LR								
		; Artems Changes	
			
		; resume registers	
		;MOV		pc, lr (Artem - I Commented this out)
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void* _signal( int signum, void *handler )
; Parameters
;   signum - a signal number (assumed to be 14 = SIGALRM)
;   handler - a pointer to a user-level signal handling function
; Return value
;   void*   - a pointer to the user-level signal handling function previously handled
;             (the same as the 2nd parameter in this project)
		EXPORT	_signal
_signal
		; save registers
		PUSH {R4-R11} ;may need to change
		; set the system call # to R7
		
		; Artems Changes
			MOV R7, #2		; SVC number for signal
        	SVC     #0x0
			MOV R0, R4		; Return handler 
			POP {R4-R11} 	;may need to change
			BX LR								
		; Artems Changes	
			
		; resume registers
		;MOV		pc, lr (Artem - I Commented this out)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		END			
