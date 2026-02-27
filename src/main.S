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

			save	r16, r17, r18, r19, r20, r21, r22, r23

			nop

			restore	r16, r17, r18, r19, r20, r21, r22, r23

			rcall	uartInit
			sendMsg	MSG_LOGO
			_CR
loop:		rcall	_INPUT
			sendMsg	MSG_OK
inloop:		rcall	getWord
			lds		r19, word_len
			tst		r19
			breq	loop
			mov		r16, r19
			rcall	printValHex
			emiti	' '
			emiti	'"'
			ldi		ZL, lo8(word_buffer)
			ldi		ZH, hi8(word_buffer)
			rcall	uartSend
			emiti	'"'
			emiti	' '
			ldi		r17, hi8(word_buffer)
			ldi		r16, lo8(word_buffer)
			movw	r14, r16
			clr		r17
			lds		r16, word_len
			rcall	_FIND
			rcall	_TCFA			
			movw	r16, ZL
			andi	r17, 0b01111111
			mov		r5, r16
			mov		r16, r17
			rcall	printValHex
			mov		r16, r5
			rcall	printValHex
			_CR
			rjmp	inloop

			rjmp	loop

			
MSG_LOGO:	.asciz	"LITE [ FORTH ] AVR v0.1"
MSG_OK:		.asciz	" ok\r\n"
			.align	1