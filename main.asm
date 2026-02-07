; ******************
; * LITE FORTH AVR *
; ******************

			.include "m328Pdef.inc"

; ========== MACROS ==========

; =========== RAM ============

; ========== CODE ============

			.def	mask    = r16
			.def	ledR    = r17
			.def	oLoopR  = r18
			.def	iLoopRL = r24
			.def	iLoopRH = r25

			.equ	oVal = 71
			.equ	iVal = 28168

			.cseg
			.org	0x00

			clr		ledR
			ldi		mask, (1<<PINB5)
			out		DDRB, mask

start:		eor		ledR, mask
			out		PORTB, ledR

			ldi		oLoopR, oVal

oLoop:		ldi		iLoopRL, low(iVal)
			ldi		iLoopRH, high(iVal)

iLoop:		sbiw	iLoopRL, 1
			brne	iLoop

			dec		oLoopR
			brne	oLoop

			rjmp	start