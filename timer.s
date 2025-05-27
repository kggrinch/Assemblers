		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Timer Definition
STCTRL		EQU		0xE000E010		; SysTick Control and Status Register
STRELOAD	EQU		0xE000E014		; SysTick Reload Value Register
STCURRENT	EQU		0xE000E018		; SysTick Current Value Register
	
STCTRL_STOP	EQU		0x00000004		; Bit 2 (CLK_SRC) = 1, Bit 1 (INT_EN) = 0, Bit 0 (ENABLE) = 0
STCTRL_GO	EQU		0x00000007		; Bit 2 (CLK_SRC) = 1, Bit 1 (INT_EN) = 1, Bit 0 (ENABLE) = 1
STRELOAD_MX	EQU		0x00FFFFFF		; MAX Value = 1/16MHz * 16M = 1 second
STCURR_CLR	EQU		0x00000000		; Clear STCURRENT and STCTRL.COUNT	
SIGALRM		EQU		14				; sig alarm

; System Variables
SECOND_LEFT	EQU		0x20007B80		; Secounds left for alarm( )
USR_HANDLER EQU		0x20007B84		; Address of a user-given signal handler function	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer initialization
; void timer_init( )
		EXPORT		_timer_init
_timer_init
        ; Stop timer by writing to control register
        LDR 	R0, =STCTRL			; Load SysTick control register address
        LDR 	R1, =STCTRL_STOP	; Load stop configuration
        STR 	R1, [R0]			; Write to control register

        ; Set reload value to maximum for full 1-second countdown
        LDR 	R0, =STRELOAD		; Load reload register address
        LDR 	R1, =STRELOAD_MX	; Load max reload value
        STR 	R1, [R0]			; Store max reload value

        ; Clear current counter value
        LDR 	R0, =STCURRENT		; Load current value register address
        LDR 	R1, =STCURR_CLR		; Load clear value
        STR 	R1, [R0]			; Write to current value register
	
        BX LR						; Return from function

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer start
; int timer_start( int seconds )
		EXPORT		_timer_start
_timer_start
		; Save previous value and set new duration
        LDR 	R1, =SECOND_LEFT	; Load seconds counter address
        LDR 	R2, [R1]        	; R2 = previous value (for return)
        STR 	R0, [R1]            ; Store new countdown duration

        ; Configure and start SysTick timer
        LDR 	R1, =STCTRL         ; Load control register address
        LDR 	R0, =STCTRL_GO      ; Config: Enable timer + interrupt
        STR 	R0, [R1]            ; Start counting

        ; Reset current counter 
        LDR 	R0, =STCURRENT		; Load current value register
        MOV 	R1, #0				; Clear value
        STR 	R1, [R0]			; Write to current value register

        ; Return previous seconds value
        MOV 	R0, R2				; Return previous duration
        BX 		LR					; Return from function

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer update
; void timer_update( )
		EXPORT		_timer_update
_timer_update
		PUSH 	{R0-R2, LR}			; Preserve registers

        ; Update countdown
        LDR 	R0, =SECOND_LEFT	; Load seconds counter address
        LDR 	R1, [R0]			; Read current value
        SUBS 	R1, R1, #1          ; Decrement seconds left
        STR 	R1, [R0]            ; Store updated value

        ; Check if counter reached zero
        CMP 	R1, #0				; Check if countdown expired
        BNE 	_update_done		; If not zero, skip handler

        ; Timer expiration sequence
        LDR 	R0, =STCTRL			; Load control register address
        LDR 	R1, =STCTRL_STOP	; Stop timer configuration
        STR 	R1, [R0]            ; Disable SysTick

        ; Execute user callback if registered
        LDR 	R0, =USR_HANDLER	; Load handler function pointer address
        LDR 	R1, [R0]			; Read handler address
        CMP 	R1, #0				; Check if NULL
        BEQ 	_update_done		; Skip if no handler
        BLX 	R1					; Call user-provided function

_update_done
        POP 	{R0-R2, LR}			; Restore registers
        BX 		LR					; Return to interrupt context

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer update
; void* signal_handler( int signum, void* handler )
	    EXPORT	_signal_handler

_signal_handler

		; Only handle SIGALRM (signal 14)
        CMP 	R0, #SIGALRM		; Check if signal is SIGALRM
        BNE 	_signal_done		; Skip if not SIGALRM

        ; Swap handler function pointer
        LDR 	R3, =USR_HANDLER	; Load handler storage address
        LDR 	R2, [R3]        	; R2 = previous handler (return value)
        STR 	R1, [R3]            ; Register new handler function


_signal_done
		MOV		R0, R2				; Return previous handler (even if no change)
        BX 		LR					; Return from function
		
		END
