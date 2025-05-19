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
        ; Stop timer
        LDR R0, =STCTRL
        LDR R1, =STCTRL_STOP
        STR R1, [R0]

        ; Set reload value
        LDR R0, =STRELOAD
        LDR R1, =STRELOAD_MX
        STR R1, [R0]

        ; Clear current value
        LDR R0, =STCURRENT
        LDR R1, =STCURR_CLR
        STR R1, [R0]

        BX LR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer start
; int timer_start( int seconds )
		EXPORT		_timer_start
_timer_start
		; Save previous value
        LDR R1, =SECOND_LEFT
        LDR R2, [R1]        ; R2 = Previous value [SECOND_LEFT = 0x20007B80]
        STR R0, [R1]        ; Store new seconds

        ; Start timer
        LDR R1, =STCTRL
        LDR R0, =STCTRL_GO
        STR R0, [R1]

        ; Clear current value
        LDR R0, =STCURRENT
        MOV R1, #0
        STR R1, [R0]

        ; Return previous value
        MOV R0, R2
        BX LR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer update
; void timer_update( )
		EXPORT		_timer_update
_timer_update
		PUSH {R0-R2, LR}

        ; Decrement counter
        LDR R0, =SECOND_LEFT
        LDR R1, [R0]
        SUBS R1, R1, #1
        STR R1, [R0]

        ; Check if reached zero
        CMP R1, #0
        BNE _update_done

        ; Stop timer
        LDR R0, =STCTRL
        LDR R1, =STCTRL_STOP
        STR R1, [R0]

        ; Call handler if not NULL
        LDR R0, =USR_HANDLER
        LDR R1, [R0]
        CMP R1, #0
        BEQ _update_done
        BLX R1

_update_done
        POP {R0-R2, LR}
        BX LR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer update
; void* signal_handler( int signum, void* handler )
	    EXPORT	_signal_handler

_signal_handler
		; Only handle SIGALRM
        CMP R0, #SIGALRM		; ADD more here | If R0 is the SIGALRM then we branch to antoher label add SIGALRM into the USR_HANDLER address and return the previous into r0
        BNE _signal_done

        ; Swap handler
        LDR R3, =USR_HANDLER
        LDR R2, [R3]        ; Return old handler
        STR R1, [R3]        ; Store new handler


_signal_done
		MOV	R0, R2			; R0 = return prevous user handler
        BX LR				; return
		
		END
