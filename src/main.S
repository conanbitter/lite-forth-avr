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
			ldi		r16, lo8(START+FLAG_PM16)
			sts		word_ptr, r16
			ldi		r16, hi8(START+FLAG_PM16)
			sts		word_ptr+1, r16
			rjmp	NEXT

			
MSG_LOGO:	.ascii	"LITE [ FORTH ] AVR v0.1 (build ", BUILD_ID, ")\0"
			.align	1

START:		.word	QUIT + FLAG_PM16