;           ******************
;           * LITE FORTH AVR *
;           ******************

			.include "m328Pdef.inc"

; ========== DEFINES =========

			.def	isCoreWord = r2
			.def	codePtrL   = r24
			.def	codePtrH   = r25

			.equ	RSTACK_SIZE       = 32 * 2
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
			.org SRAM_START
var_S0:		.byte 2
			.include "uart_head.asm"

; ========== CODE ============

			.cseg
			.org	0x00

main:
;			Stack Init
;			<- main stack | return stack -> ... RAMEND|
			ldi		r16, low(RAMEND-RSTACK_SIZE-1)
			out		SPL, r16
			sts		var_S0, r16
			ldi		r16, high(RAMEND-RSTACK_SIZE-1)
			out		SPH, r16
			sts		var_S0+1, r16
			ldi		XL, low(RAMEND-RSTACK_SIZE)
			ldi		XH, high(RAMEND-RSTACK_SIZE)

;			rcall	uartInit
;			uartMsg	LOGO_MSG
;			rcall	uartGetc
;			rcall	uartGetc

			nop

			ldi		r16, low(6553)
			ldi		r17, high(6553)
			rcall	mul16_by10u

loop:		rjmp	loop

			.include "asmwords.asm"
;			.include "constwords.asm"
;			.include "varwords.asm"
;			.include "forthwords.asm"
			.include "division.asm"
			.include "asmcodes.asm"


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
			rjmp NEXT


CODE_EXIT:	RPop [CodePtrL:CodePtrH]
			mov r16, CodePtrH
			andi CodePtrH, 0b01111111
			andi r16, 0b10000000
			mov isCoreWord, r16
			rjmp NEXT

			.include "uart_body.asm"

LOGO_MSG:	.db "LITE [ FORTH ] AVR v0.1 (build  %DAY%.%MONTH%.%YEAR% %HOUR%:%MINUTE% m328p)", 0