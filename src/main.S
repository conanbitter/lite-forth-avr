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
			_CR
loop:		rcall	_INPUT
inloop:		ldi		r16, lo8(dummy2)
			sts		word_ptr, r16
			ldi		r16, hi8(dummy2+FLAG_PM16)
			sts		word_ptr+1, r16
			rcall	getWord
			lds		r16, word_len
			tst		r16
			breq	nxtline
			ldi		r17, hi8(word_buffer)
			ldi		r16, lo8(word_buffer)
			movw	r14, r16
			clr		r17
			lds		r16, word_len
			rcall	_FIND
			tst		isError
			brne	isnum
			;rcall	_TCFA
			sts		code_ptr, ZL
			sts		code_ptr+1, ZH
			rcall	readCell
			movw	ZL, r16
			ijmp
isnum:		rcall	strToInt
			tst		isError
			brne	iserr
			push	r17
			push	r16
			rjmp	nxt
iserr:		sendMsg	MSG_UNK
			rjmp	loop
nxt:		rjmp	inloop
nxtline:	sendMsg	MSG_OK
			rjmp	loop

			
MSG_LOGO:	.asciz	"LITE [ FORTH ] AVR v0.1"
MSG_OK:		.asciz	" ok\r\n"
MSG_UNK:	.asciz	" ? "
			.align	1

dummy:		.word	pm(inloop)
dummy2:		.word	dummy + FLAG_PM16