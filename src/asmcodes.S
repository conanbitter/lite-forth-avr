; Name conventions:
; WORD_<NAME> - pointer to start of the word
; <NAME>      - pointer to codeword in the word
; CODE_<NAME> - code of the codeword
; _<NAME>     - helper function for the codeword

; Values on stack convention
; stack begin ... xH xL
;                    ^
;                    stack pointer

            #include "m328Pdef.inc"
            #include "global.inc"

			;( *chars len -- d-addr )
            .global CODE_FIND
CODE_FIND:	pop		r16					; len
			pop		r17
			pop		r14					; char pointer
			pop		r15
			rcall	_FIND
			push	ZH
			push	ZL


;================== _FIND_CORE

			#define fndcWordPtrL   r14
			#define fndcWordLenL   r16
			#define fndcWordLenH   r17
			#define fndcDWordLen   r17
			#define fndcNextDWordL r18
			#define fndcNextDWordH r19
			#define fndcIChar      r20
			#define fndcDChar      r21
			#define fndcTmp        r16

; Z = &find(chars=[r15:r14], len=[r17:r16]).codeword
; uses	R18, R19, R20, R21, Y
_FIND_CORE:	tst		fndcWordLenH
			brne	fndc_error

			ldi		ZL, lo8(LAST_CORE)
			ldi		ZH,	hi8(LAST_CORE)

fndc_wl:	lpm		fndcNextDWordL, Z+ 	; next word
			lpm		fndcNextDWordH, Z+
			lpm		fndcDWordLen, Z+

			andi	fndcDWordLen, LENGTH_MASK | FLAG_HIDDEN
			cp		fndcWordLenL, fndcDWordLen
			brne	fndc_next

			movw	YL, fndcWordPtrL

fndc_chl:	ld		fndcIChar, Y+
			lpm		fndcDChar, Z+

			cp		fndcIChar, fndcDChar
			brne	fndc_next

			dec		fndcDWordLen
			tst		fndcDWordLen
			breq	fndc_found

			rjmp	fndc_chl

fndc_next:	tst		fndcNextDWordL
			brne	fndc_next2

			tst		fndcNextDWordH
			breq	fndc_error

fndc_next2:	movw	ZL, fndcNextDWordL
			rjmp	fndc_wl

fndc_found:	sbrc	fndcWordLenL, 0
			adiw	ZL, 1
			lpm		fndcTmp, Z
			sub		ZL, fndcTmp
			sbci	ZL, 3				; - sizeof(prev) - sizeof(right_len)
			ret

fndc_error:	ldi		r16, 1
			mov		isError, r16
			clr		ZL
			clr		ZH
			ret


;================== _FIND

_FIND:		rcall	_FIND_CORE
			ori		ZH, FLAG_PM
			ret


;================== CODE_TCFA

CODE_TCFA:	pop		ZL
			pop		ZH

			rcall	_TCFA

			push	ZH
			push	ZL

			rjmp	NEXT


; Z = _TCFA(Z)
; uses R16, R17
_TCFA:		adiw	ZL, 2				; skip prev link
			
			rcall	readByte
			clr		r17
			andi	r16, LENGTH_MASK
			add		ZL, r16
			adc		ZH, r17

			sbrc	r16, 0				; skip padding
			adiw	ZL, 1

			adiw	ZL, 1				; skip right len

			ret

;================== other codes

			#define AL r16
			#define AH r17
			#define BL r18
			#define BH r19
			#define CL r12
			#define CH r13
			#define DL r14
			#define DH r15

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

			ldi		AH, hi8(word_buffer)
			ldi		AL, lo8(word_buffer)
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

			subi	AL, lo8(-1)
			sbci	AH, hi8(-1)

			push	AH
			push	AL

			rjmp	NEXT


			; ( n -- n-1 )
CODE_DEC:	pop		AL
			pop		AH

			subi	AL, lo8(1)
			sbci	AH, hi8(1)

			push	AH
			push	AL

			rjmp	NEXT


			; ( n -- n+2 )
CODE_INC2:	pop		AL
			pop		AH

			subi	AL, lo8(-2)
			sbci	AH, hi8(-2)

			push	AH
			push	AL

			rjmp	NEXT


			; ( n -- n-2 )
CODE_DEC2:	pop		AL
			pop		AH

			subi	AL, lo8(2)
			sbci	AH, hi8(2)

			push	AH
			push	AL

			rjmp	NEXT


			; ( n -- n+4 )
CODE_INC4:	pop		AL
			pop		AH

			subi	AL, lo8(-4)
			sbci	AH, hi8(-4)

			push	AH
			push	AL

			rjmp	NEXT


			; ( n -- n-4 )
CODE_DEC4:	pop		AL
			pop		AH
			subi	AL, lo8(4)
			sbci	AH, hi8(4)
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