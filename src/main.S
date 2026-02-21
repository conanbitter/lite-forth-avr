;           ******************
;           * LITE FORTH AVR *
;           ******************

            .include "m328Pdef.inc"

; ========== DEFINES =========

			isError     = 2
			isCompiling = 3

			RSTACK_SIZE    = 32 * 2
			FLAG_PM        = 0b10000000
			FLAG_IMMEDIATE = 0b10000000
			FLAG_HIDDEN    = 0b00100000
			LENGTH_MASK    = 0b00011111
			WORD_SIZE      = 32


; =========== RAM ============

			.data
var_S0:		.word   0
word_ptr:	.word   0
code_ptr:	.word   0
word_buffer:.space  WORD_SIZE

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

loop:       rjmp	loop
