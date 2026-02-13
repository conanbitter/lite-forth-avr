CODE_DROP:	pop		r16
			pop		r16
			rjmp	NEXT


CODE_SWAP:	pop		r16
			pop		r17
			pop		r18
			pop		r19
			push	r17
			push	r16
			push	r19
			push	r18
			rjmp	NEXT


CODE_DUP:	pop		r16
			pop		r17
			push	r17
			push	r16
			push	r17
			push	r16
			rjmp	NEXT


CODE_OVER:	in		YL,	SPL
    		in		YH, SPH
    		adiw	YL, 2
    		ld		r16, Y+
    		ld		r17, Y
    		push	r17
    		push	r16
			rjmp	NEXT


CODE_ROT:	pop		r14
			pop		r15
			pop		r16
			pop		r17
			pop		r18
			pop		r19
			push	r15
			push	r14
			push	r19
			push	r18
			push	r17
			push	r16
			rjmp	NEXT


CODE_NROT:	pop		r14
			pop		r15
			pop		r16
			pop		r17
			pop		r18
			pop		r19
			push	r17
			push	r16
			push	r15
			push	r14
			push	r19
			push	r18
			rjmp	NEXT
			

CODE_2DROP:	pop		r16
			pop		r16
			pop		r16
			pop		r16
			rjmp	NEXT


CODE_2SWAP:	pop		r12
			pop		r13
			pop		r14
			pop		r15
			pop		r16
			pop		r17
			pop		r18
			pop		r19
			push	r15
			push	r14
			push	r13
			push	r12
			push	r19
			push	r18
			push	r17
			push	r16
			rjmp	NEXT


CODE_2DUP:	in		YL, SPL
    		in		YH, SPH
    		ld		r16, Y+
    		ld		r17, Y+
			ld		r18, Y+
			ld		r19, Y+
    		push	r19
			push	r18
			push	r17
    		push	r16
			rjmp	NEXT


CODE_QDUP:	in		YL, SPL
    		in		YH, SPH
			ld		r16, Y+
    		ld		r17, Y+
			movw	r18, r16
			or		r18, r19
			tst		r18
			brne	CODE_QDUP_ELSE
			push	r17
			push	r16
CODE_QDUP_ELSE:
			rjmp	NEXT


CODE_INC:	pop		r16
			pop		r17
			subi	r16, low(-1)
			sbci	r17, high(-1)
			push	r17
			push	r16
			rjmp	NEXT


CODE_DEC:	pop		r16
			pop		r17
			subi	r16, low(1)
			sbci	r17, high(1)
			push	r17
			push	r16
			rjmp	NEXT


CODE_INC2:	pop		r16
			pop		r17
			subi	r16, low(-2)
			sbci	r17, high(-2)
			push	r17
			push	r16
			rjmp	NEXT


CODE_DEC2:	pop		r16
			pop		r17
			subi	r16, low(2)
			sbci	r17, high(2)
			push	r17
			push	r16
			rjmp	NEXT


CODE_INC4:	pop		r16
			pop		r17
			subi	r16, low(-4)
			sbci	r17, high(-4)
			push	r17
			push	r16
			rjmp	NEXT


CODE_DEC4:	pop		r16
			pop		r17
			subi	r16, low(4)
			sbci	r17, high(4)
			push	r17
			push	r16
			rjmp	NEXT


CODE_ADD:	pop		r16
			pop		r17
			pop		r18
			pop		r19
			add		r16, r18
			adc		r17, r19
			push	r17
			push	r16
			rjmp	NEXT


CODE_SUB:	pop		r16
			pop		r17
			pop		r18
			pop		r19
			sub		r16, r18
			sbc		r17, r19
			push	r17
			push	r16
			rjmp	NEXT


CODE_EQ:	pop		r16
			pop		r17
			pop		r18
			pop		r19
			cp		r16, r18
			brne	CODE_EQ_NOT
			cp		r17, r19
			brne	CODE_EQ_NOT
			ldi		r16, 0xFF
			rjmp	CODE_EQ_END
CODE_EQ_NOT:
			ldi		r16, 0x00
CODE_EQ_END:
			push	r16
			push	r16			
			rjmp	NEXT


CODE_NEQ:	pop		r16
			pop		r17
			pop		r18
			pop		r19
			cp		r16, r18
			brne	CODE_NEQ_NOT
			cp		r17, r19
			brne	CODE_NEQ_NOT
			ldi		r16, 0x00
			rjmp	CODE_NEQ_END
CODE_NEQ_NOT:
			ldi		r16, 0xFF
CODE_NEQ_END:
			push	r16
			push	r16			
			rjmp	NEXT