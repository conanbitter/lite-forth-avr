#ifndef	GLOBAL_INC
#define GLOBAL_INC
			#include "m328Pdef.inc"

			#define isError     r2

            RSTACK_SIZE    = 32 * 2
			STACK_BOTTOM   = RAMEND-RSTACK_SIZE-1
			FLAG_PM        = 0b10000000
			FLAG_PM16      = 0b1000000000000000
			FLAG_IMMEDIATE = 0b10000000
			FLAG_COMP_ONLY = 0b01000000
			FLAG_HIDDEN    = 0b00100000
			LENGTH_MASK    = 0b00011111
			LINE_SIZE      = 80			
			WORD_SIZE      = 32

			_EMIT  = uartPutc
			_QUERY = uartInput

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

			; ERROR CODES

			ERROR_NOERR   = 0
			ERROR_EOL     = 1
			ERROR_UNKWORD = 2
			ERROR_GENERAL = 3
			ERROR_WORDEXP = 4

#endif