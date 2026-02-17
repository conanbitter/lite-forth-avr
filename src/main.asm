;           ******************
;           * LITE FORTH AVR *
;           ******************

			.include "m328Pdef.inc"

; ========== DEFINES =========

			.def	isError     = r2
			.def	isCompiling = r3

			.equ	RSTACK_SIZE    = 32 * 2
			.equ	FLAG_PM        = 0b10000000
			.equ	FLAG_IMMEDIATE = 0b10000000
			.equ	FLAG_HIDDEN    = 0b00100000
			.equ	LENGTH_MASK    = 0b00011111
			.equ	WORD_SIZE      = 32

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
word_ptr:	.byte 2
code_ptr:	.byte 2
word_buffer:.byte WORD_SIZE

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

			clr		isError
			clr		isCompiling

			rcall	uartInit
			uartMsg	LOGO_MSG

loop:		rcall	getWord
			ldi		r17, high(word_buffer)
			ldi		r16, low(word_buffer)
			movw	r14, r16
			clr		r17
			mov		r16, r19
			rcall	_FIND_CORE
			ori		ZH, FLAG_PM
			rcall	_TCFA
			movw	r16, ZL
			andi	r17, 0b01111111
			rcall	printVal

			rjmp	loop

			.include "asmwords.asm"
;			.include "constwords.asm"
;			.include "varwords.asm"
;			.include "forthwords.asm"
			.include "uart_body.asm"
			.include "division.asm"
			.include "io.asm"
			.include "asmcodes.asm"


;================== readWord

; [R17:R16] = readWord(Z)
; Z += 2
readWord:	sbrs	ZH, 7
			rjmp	rc_ram
			andi	ZH, 0b01111111		; Z is in PM space
			lpm		r16, Z+
			lpm		r17, Z+
			ori		ZH, FLAG_PM			; restore PM flag
			ret
rc_ram:		ld		r16, Z+				; Z is in RAM space
			ld		r17, Z+
			ret


;================== readByte

; [R16] = readByte(Z)
; Z += 1
readByte:	sbrs	ZH, 7
			rjmp	rb_ram
			andi	ZH, 0b01111111		; Z is in PM space
			lpm		r16, Z+
			ori		ZH, FLAG_PM			; restore PM flag
			ret
rb_ram:		ld		r16, Z+				; Z is in RAM space
			ret


;================== NEXT

; uses R16, R17, Z
NEXT:		lds		ZL, word_ptr		; Z = WordPtr
			lds		ZH, word_ptr+1
			
			rcall	readWord			; [r17:r16] = load (addr=Z), Z+=2
			
			sts		word_ptr, ZL		; WordPtr = Z
			sts		word_ptr+1, ZH
			
			sts		code_ptr, r16		; CodePtr = [r17:r16]
			sts		code_ptr+1, r17		
			
			movw	ZL, r16				; Z = [r17:r16]
			rcall	readWord			; [r17:r16] = load (addr=Z)
			
			movw	ZL, r16				; Z = [r17:r16]
			ijmp						; jump Z


;================== CODE_DOCOL

CODE_DOCOL:	lds		r16, word_ptr		; RPush WordPtr
			lds		r17, word_ptr+1
			RPush	[r17:r16]
			
			lds		r24, code_ptr		; WordPtr = CodePtr+2
			lds		r25, code_ptr+1
			adiw	r24, 2
			sts		word_ptr, r24
			sts		word_ptr+1, r25
			
			rjmp	NEXT


;================== CODE_EXIT

CODE_EXIT:	RPop	[r17:r16]

			sts		word_ptr, r16
			sts		word_ptr+1, r17

			rjmp	NEXT


;================== CODE_BRANCH

CODE_BRANCH:lds		ZL, word_ptr			; Z = WordPtr
			lds		ZH, word_ptr+1
			rcall	readWord			; [r17:r16] = load (addr=Z)
			
			sbiw	ZL, 2				; go back to offset cell
			add		ZL, r16				; add offset to WordPtr
			adc		ZH, r17
			
			sts		word_ptr, r16
			sts		word_ptr+1, r17
			
			rjmp NEXT


;================== CODE_0BRANCH

CODE_0BRANCH:
			pop		r16					; if 0 was on stack
			pop		r17

			or		r16, r17
			tst		r16
			breq	CODE_BRANCH			; branch as usual

			lds		r24, word_ptr		; otherwise skip cell with offset value
			lds		r25, word_ptr+1

			adiw	r24, 2

			sts		word_ptr, r24
			sts		word_ptr+1, r25

			rjmp	NEXT

LOGO_MSG:	.db "LITE [ FORTH ] AVR v0.1 (build  %DAY%.%MONTH%.%YEAR% %HOUR%:%MINUTE% m328p)", 13, 0, 0
MSG_OK:		.db " ok", 0
MSG_UNKWRD:	.db	" unknown word ", 0, 0