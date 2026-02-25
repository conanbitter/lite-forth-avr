;           ******************
;           * LITE FORTH AVR *
;           ******************

            #include "m328Pdef.inc"
			#include "global.inc"

; =========== RAM ============

			.section .noinit
var_S0:		.word   0

; ========== CODE ============

			.text

            .global main

main:
;			Stack Init
;			<- main stack | return stack -> ... RAMEND|
			ldi		r16, lo8(RAMEND-RSTACK_SIZE-1)
			out		SPL, r16
			sts		var_S0, r16
			ldi		r16, hi8(RAMEND-RSTACK_SIZE-1)
			out		SPH, r16
			sts		var_S0+1, r16
			ldi		XL, lo8(RAMEND-RSTACK_SIZE)
			ldi		XH, hi8(RAMEND-RSTACK_SIZE)

            clr		isError
			clr		isCompiling

			rcall	uartInit
			sendMsg	MSG_LOGO

loop:		_CR
/*			rcall	getWord
			ldi		r16, 13
			rcall	_EMIT
			ldi		r16, 10
			rcall	_EMIT
			ldi		r17, hi8(word_buffer)
			ldi		r16, lo8(word_buffer)
			movw	r14, r16
			clr		r17
			mov		r16, r19
			rcall	_FIND
			rcall	_TCFA
			movw	r16, ZL
			andi	r17, 0b01111111
			mov		r5, r16
			mov		r16, r17
			rcall	printValHex
			mov		r16, r5
			rcall	printValHex*/
			rcall	_INPUT
			sendMsg	MSG_OK
			ldi		ZL, lo8(line_buffer)
			ldi		ZH, hi8(line_buffer)
			rcall	uartSend

			rjmp	loop

			
MSG_LOGO:	.asciz	"LITE [ FORTH ] AVR v0.1"
MSG_OK:		.asciz	" ok\r\n"
			.align	1