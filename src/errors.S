			#include "global.inc"

			.text

			.global	CODE_ERRTST
CODE_ERRTST:
			pop		r16
			pop		r17

			tst		r16					; 0 - no error
			brne	et_1
			rjmp	NEXT

et_1:		cpi		r16, ERROR_EOL		; 1 - input buffer is empty (End Of Line)
			brne	et_other			; print " ok"
			lds		r17, VAR_STATE
			tst		r17
			brne	et_1e
			sendMsg	MSG_OK
et_1e:		rjmp	NEXT

et_other:	push	r16
			rjmp	CODE_ERROR



			.global CODE_ERROR
CODE_ERROR:	pop		r16
			cpi		r16, ERROR_UNKWORD	; 2 - unknown word 
			brne	err_other			; print " ? "+word_buffer

			sendMsg	MSG_UNK

			ldi		ZL, lo8(word_buffer)
			ldi		ZH, hi8(word_buffer)
			rcall	uartSend

			rjmp	err_reset

err_other:	subi	r16, 3				; codes 3.. will be	0..
			clr		r17
			lsl		r16					; index -> address offset
			rol		r17

			ldi		ZL, lo8(ERR_TABLE)	; load message address from error table
			ldi		ZH, hi8(ERR_TABLE)

			add		ZL, r16
			adc		ZH, r17

			lpm		r16, Z+
			lpm		r17, Z

			movw	ZL, r16
			rcall	uartSendPm

			;rjmp	err_reset

err_reset:	; reset stacks
			; reset state
			; restore HERE
			; jump to quit (start)
			rjmp	NEXT



			.global MSG_OK
			.global MSG_UNK
MSG_OK:		.asciz	" ok"
MSG_UNK:	.asciz	" ? "

; Error messages table

ERR_TABLE:	.word	ERR_GEN, ERR_WEX

ERR_GEN:	.asciz	" error"
ERR_WEX:	.asciz	" error: word expected"

			.align	1