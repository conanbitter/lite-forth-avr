; ******************
; * LITE FORTH AVR *
; ******************

			.include "m328Pdef.inc"

; ========== DEFINES =========

			.def	wordIsCore = r2
			.def	codePtr    = r22
			.def	codePtrH   = r23

; ========== MACROS ==========

; =========== RAM ============

			.dseg
test4:		.byte 2

; ========== CODE ============

			.cseg
			.org	0x00

test1:		nop
;			ldi		codePtr, low(test2*2)
;			ldi		codePtrH, high(test2*2)
;			ldi		r16, 1
			ldi		codePtr, low(test4)
			ldi		codePtrH, high(test4)
			ldi		r16, 0
			mov		wordIsCore, r16
			ldi		r16, low(test5)
			sts		test4, r16
			ldi		r16, high(test5)
			sts		test4+1, r16
			nop
test3:		nop
			nop
test5:		nop
			nop
			nop
			rjmp	NEXT
			nop

NEXT:		movw	ZL, codePtr			; Z = codePtr
			subi	codePtr, low(-2)	; codePtr += 2
			sbci	codePtrH, high(-2)
			tst		wordIsCore			; Z = *Z {
			brne	NEXT_ELSE
			ld		r16, Z+				; temp = *Z  (from RAM)
			ld		r17, Z
			rjmp	NEXT_ENDIF
NEXT_ELSE:	lpm		r16, Z+				; temp = *Z  (from Flash)
			lpm		r17, Z
NEXT_ENDIF:	movw	ZL, r16				; Z = temp }
			ijmp						; goto Z

			.org	0x7F
test2:		.dw		test3