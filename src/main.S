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

loop:		sendMsg	hello_msg
			rcall	uartGetc
			sendMsg	hello_msg2
			ldi		ZL, lo8(uart_buf)
			ldi		ZH, hi8(uart_buf)
			rcall	uartSend
			rjmp	loop

			.align 2
hello_msg:	.asciz	"\r\nHello World!\r\nEnter your name\r\n>"
hello_msg2:	.asciz	"\r\nHello, "