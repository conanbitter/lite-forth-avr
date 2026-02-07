; ******************
; * LITE FORTH AVR *
; ******************

			.include "m328Pdef.inc"

; ========== MACROS ==========

; =========== RAM ============

; ========== CODE ============

			.cseg
			.org 0x00

			ldi		r16, (1<<PINB0)
			out		DDRB, r16
			out		PORTB, r16

loop:		rjmp	loop