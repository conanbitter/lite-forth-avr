            #include "m328Pdef.inc"
			#include "global.inc"

			.section .noinit

			.global word_ptr
word_ptr:	.word   0

			.global code_ptr
code_ptr:	.word   0

			.global VAR_ERRCODE
VAR_ERRCODE:.word   0

			.text



;================== readCell
;
; in Z - d-addr of the cell 
;   (Z is pointing to the next cell after return)
;
; out [R17:R16] - value from the cell
;
;==================
            .global readCell
readCell:	sbrs	ZH, 7
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
;
; in Z - d-addr of the byte
;   (Z is pointing to the next byte after return)
;
; out R16 - readed value
;
;==================
            .global readByte
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
            .global NEXT
NEXT:		lds		ZL, word_ptr		; Z = WordPtr
			lds		ZH, word_ptr+1
			
			rcall	readCell			; [r17:r16] = load (addr=Z), Z+=2
			
			sts		word_ptr, ZL		; WordPtr = Z
			sts		word_ptr+1, ZH
			
			sts		code_ptr, r16		; CodePtr = [r17:r16]
			sts		code_ptr+1, r17		
			
			movw	ZL, r16				; Z = [r17:r16]
			rcall	readCell			; [r17:r16] = load (addr=Z)
			
			movw	ZL, r16				; Z = [r17:r16]
			ijmp						; jump Z



;================== CODE_DOCOL

            .global CODE_DOCOL
CODE_DOCOL:	lds		r16, word_ptr		; RPush WordPtr
			lds		r17, word_ptr+1
			RPush	r17, r16
			
			lds		r24, code_ptr		; WordPtr = CodePtr+2
			lds		r25, code_ptr+1
			adiw	r24, 2
			sts		word_ptr, r24
			sts		word_ptr+1, r25
			
			rjmp	NEXT



;================== CODE_EXIT

            .global CODE_EXIT
CODE_EXIT:	RPop	r17, r16

			sts		word_ptr, r16
			sts		word_ptr+1, r17

			rjmp	NEXT



;================== CODE_BRANCH

            .global CODE_BRANCH
CODE_BRANCH:lds		ZL, word_ptr		; Z = WordPtr
			lds		ZH, word_ptr+1
			rcall	readCell			; [r17:r16] = load (addr=Z)
			
			add		ZL, r16				; add offset to WordPtr
			adc		ZH, r17
			
			sts		word_ptr, ZL
			sts		word_ptr+1, ZH
			
			rjmp NEXT



;================== CODE_ZBRANCH

            .global CODE_ZBRANCH
CODE_ZBRANCH:
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



;================== CODE_LIT

			.global	CODE_LIT
CODE_LIT:	lds		ZL, word_ptr			; Z = WordPtr
			lds		ZH, word_ptr+1
			rcall	readCell				; [r17:r16] = load (addr=Z)

			push	r17						; push value to the stack
			push	r16

			sts		word_ptr, ZL			; store next address to word_ptr
			sts		word_ptr+1, ZH

			rjmp	NEXT