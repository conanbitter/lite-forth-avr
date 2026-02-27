			#define isError     r2
			#define isCompiling r3

            RSTACK_SIZE    = 32 * 2
			FLAG_PM        = 0b10000000
			FLAG_IMMEDIATE = 0b10000000
			FLAG_COMP_ONLY = 0b01000000
			FLAG_HIDDEN    = 0b00100000
			LENGTH_MASK    = 0b00011111
			LINE_SIZE      = 80			
			WORD_SIZE      = 32

			_EMIT  = uartPutc
			_INPUT = uartInput

.macro      sendMsg msgAddr
			ldi		ZL, lo8(\msgAddr)
			ldi		ZH, hi8(\msgAddr)
			rcall	uartSendPm
.endm

.macro		RPush	RH, RL
			st		X+, \RH
			st		X+, \RL
.endm

.macro		RPop	RH, RL
			ld		\RL, -X
			ld		\RH, -X
.endm

.macro		emiti	char
			ldi		r16, \char
			rcall	_EMIT
.endm

.macro		_CR
			emiti	13
			emiti	10
.endm

.macro		save	reg, other:vararg
			.ifnb	\reg
			push	\reg
			save	\other
			.endif
.endm

.macro		restore	reg, other:vararg
			.ifnb	\reg
			restore	\other
			pop		\reg
			.endif
.endm
