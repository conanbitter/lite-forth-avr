;           ******************
;           * LITE FORTH AVR *
;           ******************

			.include "m328Pdef.inc"

; ========== DEFINES =========

			.def	isCoreWord = r2
			.def	codePtrL   = r24
			.def	codePtrH   = r25

			.equ	RSTACK_SIZE = 32 * 2
			.equ	FLAG_IS_CORE_WORD = 0b10000000

; ========== MACROS ==========

			.macro RPush
				.message "RPush no parameters specified"
			.endm

			.macro RPush_16
			st		X+, @0
			st		X+, @1
			.endm

			.macro RPop
				.message "RPop no parameters specified"
			.endm

			.macro RPop_16
			ld		@1, -X
			ld		@0, -X
			.endm

; =========== RAM ============

			.dseg
test4:		.byte 2

; ========== CODE ============

			.cseg
			.org	0x00

main:
;			Stack Init
;			<- main stack | return stack -> ... RAMEND|
			ldi		r16, low(RAMEND-RSTACK_SIZE-1)
			out		SPL, r16
			ldi		r16, high(RAMEND-RSTACK_SIZE-1)
			out		SPH, r16
			ldi		XL, low(RAMEND-RSTACK_SIZE)
			ldi		XH, high(RAMEND-RSTACK_SIZE)

test1:		nop
			ldi		codePtrL, low(test2*2)
			ldi		codePtrH, high(test2*2)
			ldi		r16, FLAG_IS_CORE_WORD
			mov		isCoreWord, r16
			rcall	CODE_DOCOL_CORE
			ldi		codePtrL, low(test4)
			ldi		codePtrH, high(test4)
			ldi		r16, 0
			mov		isCoreWord, r16
			rcall	CODE_EXIT			
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


NEXT:		movw	ZL, codePtrL		; Z = codePtr
			adiw	codePtrL, 2			; codePtr += 2
			tst		isCoreWord			; Z = *Z {
			brne	NEXT_ELSE
			ld		r16, Z+				; temp = *Z  (from RAM)
			ld		r17, Z
			rjmp	NEXT_ENDIF
NEXT_ELSE:	lpm		r16, Z+				; temp = *Z  (from Flash)
			lpm		r17, Z
NEXT_ENDIF:	movw	ZL, r16				; Z = temp }
			ijmp						; goto Z


CODE_DOCOL_CORE:
			mov r16, CodePtrH
			or r16, isCoreWord
			RPush [CodePtrL:r16]
			adiw ZL, 2					; Z += 2
			movw CodePtrL, ZL			; CodePtr = Z
			ldi r16, FLAG_IS_CORE_WORD	; wordIsCore = true
			mov isCoreWord, r16
;			NEXT
			ret


CODE_EXIT:	RPop [CodePtrL:CodePtrH]
			mov r16, CodePtrH
			andi CodePtrH, 0b01111111
			andi r16, 0b10000000
			mov isCoreWord, r16
;			NEXT
			ret

			.org	0x7F
test2:		.dw		test3