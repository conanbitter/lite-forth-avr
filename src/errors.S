			#include "global.inc"

			.text

			.global	CODE_ERRDISP
CODE_ERRDISP:
			pop		r16
			pop		r17

			tst		r16					; 0 - no error
			brne	ed_1
			rjmp	NEXT

ed_1:		dec		r16					; 1 - empty input buffer
			tst		r16					; print " ok"
			brne	ed_2
			tst		isCompiling
			brne	ed_1e
			sendMsg	MSG_OK
ed_1e:		rjmp	NEXT

ed_2:		dec		r16					; 2 - unknown word 
			tst		r16					; print " ? "+word_buffer
			brne	ed_3
			sendMsg	MSG_UNK
			ldi		ZL, lo8(word_buffer)
			ldi		ZH, hi8(word_buffer)
			rcall	uartSend
			rjmp	NEXT

ed_3:		dec		r16					; 3 - other errors
			tst		r16					; print " error"
			brne	ed_2
			sendMsg	MSG_ERR
			rjmp	NEXT


			.global MSG_OK
			.global MSG_UNK
MSG_OK:		.asciz	" ok"
MSG_UNK:	.asciz	" ? "
MSG_ERR:	.asciz	" error"
			.align	1