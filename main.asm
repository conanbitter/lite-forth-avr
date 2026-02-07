; ******************
; * LITE FORTH AVR *
; ******************

			.include "m328Pdef.inc"

; ========== DEFINES =========

			.def	codePtr  = r22
			.def	codePtrH = r23

; ========== MACROS ==========

		.macro NEXT_STATIC
			movw	ZL, codePtr			; Z = codePtr
			subi	codePtr, low(-2)	; codePtr += 2
			sbci	codePtrH, high(-2)
			lpm		r16, z+				; Z = *Z { temp = *Z
			lpm		r17, z
			movw	ZL, r16				; Z = temp }
			ijmp						; goto Z
		.endm

; =========== RAM ============

; ========== CODE ============

			.cseg
			.org	0x00

test1:		ldi		codePtr, low(test2*2)
			ldi		codePtrH, high(test2*2)
			nop
test3:		nop
			nop
			nop
			NEXT_STATIC
			nop

			.org	0x7F
test2:		.dw		test3