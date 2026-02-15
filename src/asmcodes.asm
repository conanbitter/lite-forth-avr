; Name conventions:
; WORD_<NAME> - pointer to start of the word
; <NAME>      - pointer to codeword in the word
; CODE_<NAME> - code of the codeword
; _<NAME>     - helper function for the codeword

; Values on stack convention
; stack begin ... xH xL
;                    ^
;                    stack pointer

			.def	AL = r16
			.def	AH = r17
			.def	BL = r18
			.def	BH = r19
			.def	CL = r12
			.def	CH = r13
			.def	DL = r14
			.def	DH = r15

			; ( -- char )
CODE_KEY:	rcall	_KEY
			clr		AH

			push	AH
			push	AL

			rjmp	NEXT


			; ( char -- )
CODE_EMIT:	pop		AL
			pop		AH
			rcall	_EMIT

			rjmp	NEXT


			; ( -- *char len:u16 )
CODE_WORD:	rcall	getWord

			ldi		AH, high(word_buffer)
			ldi		AL, low(word_buffer)
			push	AH
			push	AL

			clr		AL
			push	AL
			push	r19

			rjmp	NEXT


			; ( n -- )
CODE_DROP:	pop		AL
			pop		AL

			rjmp	NEXT


			; ( n1 n2 -- n2 n1 )
CODE_SWAP:	pop		AL
			pop		AH

			pop		BL
			pop		BH

			push	AH
			push	AL

			push	BH
			push	BL

			rjmp	NEXT


			; ( n -- n n )
CODE_DUP:	pop		AL
			pop		AH

			push	AH
			push	AL

			push	AH
			push	AL

			rjmp	NEXT


			; ( n1 n2 -- n1 n2 n1 )
CODE_OVER:	in		YL,	SPL
    		in		YH, SPH
    		adiw	YL, 2

    		ld		AL, Y+
    		ld		AH, Y

    		push	AH
    		push	AL

			rjmp	NEXT


			; ( n1 n2 n3 -- n3 n1 n2 )
CODE_ROT:	pop		CL
			pop		CH

			pop		AL
			pop		AH

			pop		BL
			pop		BH

			push	CH
			push	CL

			push	BH
			push	BL

			push	AH
			push	AL

			rjmp	NEXT


			; ( n1 n2 n3 -- n2 n3 n1 )
CODE_NROT:	pop		CL
			pop		CH

			pop		AL
			pop		AH

			pop		BL
			pop		BH

			push	AH
			push	AL

			push	CH
			push	CL

			push	BH
			push	BL

			rjmp	NEXT
			

			; ( n1 n2 -- )
CODE_2DROP:	pop		AL
			pop		AL

			pop		AL
			pop		AL

			rjmp	NEXT


			; ( n1 n2 n3 n4 -- n3 n4 n1 n2 )
CODE_2SWAP:	pop		DL
			pop		DH

			pop		CL
			pop		CH

			pop		BL
			pop		BH

			pop		AL
			pop		AH

			push	CH
			push	CL

			push	DH
			push	DL

			push	AH
			push	AL

			push	BH
			push	BL
			
			rjmp	NEXT


			; ( n1 n2 -- n1 n2 n1 n2 )
CODE_2DUP:	in		YL, SPL
    		in		YH, SPH

			ld		BL, Y+
			ld		BH, Y+

    		ld		AL, Y+
    		ld		AH, Y+

			push	AH
    		push	AL

    		push	BH
			push	BL

			rjmp	NEXT


			; ( n -- n!=0 ? n n : n)
CODE_QDUP:	in		YL, SPL
    		in		YH, SPH
			ld		AL, Y+
    		ld		AH, Y+

			movw	BL, AL
			or		BL, BH
			tst		BL
			brne	CODE_QDUP_ELSE

			push	AH
			push	AL
CODE_QDUP_ELSE:
			rjmp	NEXT


			; ( n -- n+1 )
CODE_INC:	pop		AL
			pop		AH

			subi	AL, low(-1)
			sbci	AH, high(-1)

			push	AH
			push	AL

			rjmp	NEXT


			; ( n -- n-1 )
CODE_DEC:	pop		AL
			pop		AH

			subi	AL, low(1)
			sbci	AH, high(1)

			push	AH
			push	AL

			rjmp	NEXT


			; ( n -- n+2 )
CODE_INC2:	pop		AL
			pop		AH

			subi	AL, low(-2)
			sbci	AH, high(-2)

			push	AH
			push	AL

			rjmp	NEXT


			; ( n -- n-2 )
CODE_DEC2:	pop		AL
			pop		AH

			subi	AL, low(2)
			sbci	AH, high(2)

			push	AH
			push	AL

			rjmp	NEXT


			; ( n -- n+4 )
CODE_INC4:	pop		AL
			pop		AH

			subi	AL, low(-4)
			sbci	AH, high(-4)

			push	AH
			push	AL

			rjmp	NEXT


			; ( n -- n-4 )
CODE_DEC4:	pop		AL
			pop		AH
			subi	AL, low(4)
			sbci	AH, high(4)
			push	AH
			push	AL
			rjmp	NEXT


			; ( n1 n2 -- n1+n2 )
CODE_ADD:	pop		BL
			pop		BH

			pop		AL
			pop		AH			

			add		AL, BL
			adc		AH, BH

			push	AH
			push	AL

			rjmp	NEXT


			; ( n1 n2 -- n1-n2 )
CODE_SUB:	pop		BL
			pop		BH

			pop		AL
			pop		AH
			
			sub		AL, BL
			sbc		AH, BH

			push	AH
			push	AL

			rjmp	NEXT


			; ( n1 n2 -- n1==n2 )
CODE_EQ:	pop		BL
			pop		BH

			pop		AL
			pop		AH
			
			cp		AL, BL
			brne	CODE_EQ_NOT
			cp		AH, BH
			brne	CODE_EQ_NOT

			ldi		AL, 0xFF
			rjmp	CODE_EQ_END

CODE_EQ_NOT:
			ldi		AL, 0x00

CODE_EQ_END:
			push	AL
			push	AL

			rjmp	NEXT


			; ( n1 n2 -- n1!=n2 )
CODE_NEQ:	pop		BL
			pop		BH

			pop		AL
			pop		AH
			
			cp		AL, BL
			brne	CODE_NEQ_NOT
			cp		AH, BH
			brne	CODE_NEQ_NOT

			ldi		AL, 0x00
			rjmp	CODE_NEQ_END

CODE_NEQ_NOT:
			ldi		AL, 0xFF

CODE_NEQ_END:
			push	AL
			push	AL

			rjmp	NEXT