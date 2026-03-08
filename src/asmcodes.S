; Name conventions:
; WORD_<NAME> - pointer to start of the word
; <NAME>      - pointer to codeword in the word
; CODE_<NAME> - code of the codeword
; _<NAME>     - helper function for the codeword

; Values on stack convention
; stack begin ... xH xL
;                    ^
;                    stack pointer

            #include "global.inc"

			.text

			.global	CODE_CREATE
CODE_CREATE:rcall	getWord
			lds		YL, VAR_HERE		; load userdata pointer to Y
			lds		YH, VAR_HERE+1
			movw	r16, YL				; keep start of the word

			lds		r18, VAR_LATEST		; save pointer to previous word
			st		Y+, r18
			lds		r18, VAR_LATEST+1
			st		Y+, r18
			sts		VAR_LATEST, r16		; update LATEST
			sts		VAR_LATEST+1, r17

			lds		r16, word_len		; save word length (clean)
			st		Y+, r16

			ldi		ZL, lo8(word_buffer)
			ldi		ZH, hi8(word_buffer)
1:			ld		r16, Z+
			tst		r16
			breq	2f
			st		Y+, r16
			rjmp	1b

2:			lds		r16, word_len		; save word length (padded)
			sbrs	r16, 0
			rjmp	3f
			subi	r16, -1
			clr		r17
			st		Y+, r17
3:			st		Y+, r16

			sts		VAR_HERE, YL		; update HERE
			sts		VAR_HERE+1, YH

			rjmp	NEXT



			.global	CODE_COMMA
CODE_COMMA:	pop		r16
			pop		r17

			rcall	_COMMA

			rjmp	NEXT


_COMMA:		save	YL, YH
			lds		YL, VAR_HERE		; load userdata pointer to Y
			lds		YH, VAR_HERE+1

			st		Y+, r16
			st		Y+, r17

			sts		VAR_HERE, YL		; update HERE
			sts		VAR_HERE+1, YH

			restore	YL, YH
			ret



			.global	CODE_LBRAC
CODE_LBRAC:	clr		r16
			sts		VAR_STATE, r16
			sts		VAR_STATE+1, r16

			rjmp NEXT



			.global	CODE_RBRAC
CODE_RBRAC:	ldi		r16, 0xFF
			sts		VAR_STATE, r16
			sts		VAR_STATE+1, r16

			rjmp NEXT



			.global	CODE_HIDDEN
CODE_HIDDEN:pop		YL
			pop		YH
			adiw	YL, 2
			ld		r16, Y
			sbrc	r16, 5
			rjmp	ch_clear
			ori		r16, FLAG_HIDDEN
			rjmp	ch_end
ch_clear:	andi	r16, ~FLAG_HIDDEN
ch_end:		st		Y, r16
			rjmp	NEXT



			.global	CODE_IMMEDIATE
CODE_IMMEDIATE:
			lds		YL, VAR_LATEST
			lds		YH, VAR_LATEST+1
			adiw	YL, 2
			ld		r16, Y
			sbrc	r16, 7
			rjmp	ci_clear
			ori		r16, FLAG_IMMEDIATE
			rjmp	ci_end
ci_clear:	andi	r16, ~FLAG_IMMEDIATE
ci_end:		st		Y, r16
			rjmp	NEXT


			.global CODE_QUERY
CODE_QUERY:	rcall	_QUERY
			rjmp	NEXT



			.global CODE_CR
CODE_CR:	_CR
			rjmp	NEXT



			.global CODE_PARSE
CODE_PARSE:	rcall	getWord
			lds		r5, VAR_STATE
			lds		r16, word_len
			tst		r16
			brne	prs_isword
			ldi		r16, ERROR_EOL		; return code 1
			sts		VAR_ERRCODE, r16
			rjmp	NEXT

prs_isword:	ldi		r17, hi8(word_buffer)
			ldi		r16, lo8(word_buffer)
			movw	r14, r16

			clr		r17
			lds		r16, word_len
			rcall	_FIND

			tst		isError
			brne	prs_isnum

			clr		r16					; return code 0
			sts		VAR_ERRCODE, r16

			tst		r5					; is compile mode
			breq	prs_wint
			movw	r6, ZL				; save CFA
			rcall	_TWHA				; ged immed flag
			adiw	ZL, 2				; skip prev link
			
			rcall	readByte
			andi	r16, FLAG_IMMEDIATE
			breq	prs_wcomp
			movw	ZL, r6				; restore CFA

prs_wint:	sts		code_ptr, ZL		; run word
			sts		code_ptr+1, ZH
			rcall	readCell
			movw	ZL, r16

			ijmp

prs_wcomp:	movw	r16, r6				; write CFA
			rcall	_COMMA
			rjmp	NEXT

prs_isnum:	rcall	strToInt
			tst		isError
			brne	prs_unk

			clr		r15					; return code 0
			sts		VAR_ERRCODE, r15
			
			tst		r5					; is compile mode
			breq	prs_nint

prs_ncomp:	movw	r6, r16				; save number

			ldi		r16, lo8(LIT + FLAG_PM16)
			ldi		r17, hi8(LIT + FLAG_PM16)
			rcall	_COMMA				; write LIT

			movw	r16, r6				; write number
			rcall	_COMMA
			rjmp	NEXT

prs_nint:	push	r17					; run number
			push	r16

			rjmp	NEXT

prs_unk:	ldi		r16, ERROR_UNKWORD	; return code 2
			sts		VAR_ERRCODE, r16

			rjmp	NEXT



			; ( *chars len -- d-addr )
            .global CODE_FIND
CODE_FIND:	pop		r16					; len
			pop		r17
			pop		r14					; char pointer
			pop		r15
			rcall	_FIND
			rcall	_TWHA
			push	ZH
			push	ZL



;================== _FIND_CORE
;
; in [r15:r14] - address of the string
;    [r17:r16] - 16 bit length of the string
;
; out Z - d-addr of the found word or 0
;
;==================

			#define fndcWordPtrL   r14
			#define fndcWordLenL   r16
			#define fndcWordLenH   r17
			#define fndcDWordLen   r17
			#define fndcNextDWordL r18
			#define fndcNextDWordH r19
			#define fndcIChar      r20
			#define fndcDChar      r21
			#define fndcTmp        r16

_FIND_CORE:	save	r14, r15, r16, r17, r18, r19, r20, r21, YL, YH
			tst		fndcWordLenH
			brne	fndc_error

			ldi		ZL, lo8(LAST_CORE)
			ldi		ZH,	hi8(LAST_CORE)
			lpm		YL, Z+
			lpm		YH, Z
			movw	ZL, YL

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
			adiw	ZL, 1
			;lpm		fndcTmp, Z
			;sub		ZL, fndcTmp
			;sbci	ZL, 3				; - sizeof(prev) - sizeof(right_len)
			clr		isError
			restore	r14, r15, r16, r17, r18, r19, r20, r21, YL, YH
			ret

fndc_error:	ldi		r16, 1
			mov		isError, r16
			clr		ZL
			clr		ZH
			restore	r14, r15, r16, r17, r18, r19, r20, r21, YL, YH
			ret



;================== _FIND_RAM
;
; in [r15:r14] - address of the string
;    [r17:r16] - 16 bit length of the string
;
; out Z - d-addr of the found word or 0
;
;==================

			#define fndrWordPtrL   r14
			#define fndrWordLenL   r16
			#define fndrWordLenH   r17
			#define fndrDWordLen   r17
			#define fndrNextDWordL r18
			#define fndrNextDWordH r19
			#define fndrIChar      r20
			#define fndrDChar      r21
			#define fndrTmp        r16

_FIND_RAM:	save	r14, r15, r16, r17, r18, r19, r20, r21, YL, YH
			tst		fndrWordLenH
			brne	fndr_error

			lds		ZL, VAR_LATEST
			lds		ZH,	VAR_LATEST+1

fndr_wl:	ld		fndrNextDWordL, Z+ 	; next word
			ld		fndrNextDWordH, Z+
			ld		fndrDWordLen, Z+

			andi	fndrDWordLen, LENGTH_MASK | FLAG_HIDDEN
			cp		fndrWordLenL, fndrDWordLen
			brne	fndr_next

			movw	YL, fndrWordPtrL

fndr_chl:	ld		fndrIChar, Y+
			ld		fndrDChar, Z+

			cp		fndrIChar, fndrDChar
			brne	fndr_next

			dec		fndrDWordLen
			tst		fndrDWordLen
			breq	fndr_found

			rjmp	fndr_chl

fndr_next:	tst		fndrNextDWordL
			brne	fndr_next2

			tst		fndrNextDWordH
			breq	fndr_error

fndr_next2:	movw	ZL, fndrNextDWordL
			rjmp	fndr_wl

fndr_found:	sbrc	fndrWordLenL, 0
			adiw	ZL, 1
			adiw	ZL, 1
			;lpm		fndcTmp, Z
			;sub		ZL, fndcTmp
			;sbci	ZL, 3				; - sizeof(prev) - sizeof(right_len)
			clr		isError
			restore	r14, r15, r16, r17, r18, r19, r20, r21, YL, YH
			ret

fndr_error:	ldi		r16, 1
			mov		isError, r16
			clr		ZL
			clr		ZH
			restore	r14, r15, r16, r17, r18, r19, r20, r21, YL, YH
			ret



;================== _FIND

            .global _FIND
_FIND:		rcall	_FIND_RAM
			tst		isError
			brne	1f
			ret

1:			rcall	_FIND_CORE
			tst		isError
			brne	2f
			ori		ZH, FLAG_PM
2:			ret



;================== CODE_TCFA

            .global CODE_TCFA
CODE_TCFA:	pop		ZL
			pop		ZH

			rcall	_TCFA

			push	ZH
			push	ZL

			rjmp	NEXT


; Z = _TCFA(Z)
            .global _TCFA
_TCFA:		save	r16, r17
			adiw	ZL, 2				; skip prev link
			
			rcall	readByte
			clr		r17
			andi	r16, LENGTH_MASK
			add		ZL, r16
			adc		ZH, r17

			sbrc	r16, 0				; skip padding
			adiw	ZL, 1

			adiw	ZL, 1				; skip right len

			restore	r16, r17
			ret



;================== _TWHA
; Word head from CFA
;
; Z = _TWHA(Z)
;
;==================
			.global	_TWHA
_TWHA:		save	r17
			sbiw	ZL, 1				; go to right len
			rcall	readByte

			clr		r17
			sub		ZL, r16
			sbc		ZH, r17

			sbiw	ZL, 4				; 1b right len + 1b left len + 2b prev link 

			restore	r17
			ret


;================== CODE_DOT
			.global	CODE_DOT
CODE_DOT:	emiti	' '

			pop		r16
			pop		r17
			rcall	printVal
			
			rjmp	NEXT



;================== CODE_PSTACK
			.global	CODE_PSTACK
CODE_PSTACK:
			in		YL, SPL
			in		YH, SPH
			adiw	YL, 1
pst_loop:	cpi		YL, lo8(STACK_BOTTOM)
			brlo	pst_read
			cpi 	YH, hi8(STACK_BOTTOM)
			brge	pst_end
pst_read:	emiti	' '
			ld		r16, Y+
			ld		r17, Y+
			rcall 	printVal
			rjmp	pst_loop

pst_end:	rjmp	NEXT


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
            .global CODE_KEY
CODE_KEY:	rcall	_KEY
			clr		AH

			push	AH
			push	AL

			rjmp	NEXT


			; ( char -- )
            .global CODE_EMIT
CODE_EMIT:	pop		AL
			pop		AH
			rcall	_EMIT

			rjmp	NEXT


			; ( -- *char len:u16 )
            .global CODE_WORD
CODE_WORD:	rcall	getWord

			ldi		AH, hi8(word_buffer)
			ldi		AL, lo8(word_buffer)
			push	AH
			push	AL

			clr		AL
			push	AL
			lds		AL, word_len
			push	AL

			rjmp	NEXT


			; ( n -- )
            .global CODE_DROP
CODE_DROP:	pop		AL
			pop		AL

			rjmp	NEXT


			; ( n1 n2 -- n2 n1 )
            .global CODE_SWAP
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
            .global CODE_DUP
CODE_DUP:	pop		AL
			pop		AH

			push	AH
			push	AL

			push	AH
			push	AL

			rjmp	NEXT


			; ( n1 n2 -- n1 n2 n1 )
            .global CODE_OVER
CODE_OVER:	in		YL,	SPL
    		in		YH, SPH
    		adiw	YL, 3

    		ld		AL, Y+
    		ld		AH, Y

    		push	AH
    		push	AL

			rjmp	NEXT


			; ( n1 n2 n3 -- n3 n1 n2 )
            .global CODE_ROT
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
            .global CODE_NROT
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
            .global CODE_DROP2
CODE_DROP2:	pop		AL
			pop		AL

			pop		AL
			pop		AL

			rjmp	NEXT


			; ( n1 n2 n3 n4 -- n3 n4 n1 n2 )
            .global CODE_SWAP2
CODE_SWAP2:	pop		DL
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
            .global CODE_DUP2
CODE_DUP2:	in		YL, SPL
    		in		YH, SPH
			adiw	YL, 1

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
            .global CODE_QDUP
CODE_QDUP:	in		YL, SPL
    		in		YH, SPH
			adiw	YL, 1
			ld		AL, Y+
    		ld		AH, Y+

			movw	BL, AL
			or		BL, BH
			tst		BL
			breq	CODE_QDUP_ELSE

			push	AH
			push	AL
CODE_QDUP_ELSE:
			rjmp	NEXT


			; ( n -- n+1 )
            .global CODE_INC
CODE_INC:	pop		AL
			pop		AH

			subi	AL, lo8(-1)
			sbci	AH, hi8(-1)

			push	AH
			push	AL

			rjmp	NEXT


			; ( n -- n-1 )
            .global CODE_DEC
CODE_DEC:	pop		AL
			pop		AH

			subi	AL, lo8(1)
			sbci	AH, hi8(1)

			push	AH
			push	AL

			rjmp	NEXT


			; ( n -- n+2 )
            .global CODE_INC2
CODE_INC2:	pop		AL
			pop		AH

			subi	AL, lo8(-2)
			sbci	AH, hi8(-2)

			push	AH
			push	AL

			rjmp	NEXT


			; ( n -- n-2 )
            .global CODE_DEC2
CODE_DEC2:	pop		AL
			pop		AH

			subi	AL, lo8(2)
			sbci	AH, hi8(2)

			push	AH
			push	AL

			rjmp	NEXT


			; ( n -- n+4 )
            .global CODE_INC4
CODE_INC4:	pop		AL
			pop		AH

			subi	AL, lo8(-4)
			sbci	AH, hi8(-4)

			push	AH
			push	AL

			rjmp	NEXT


			; ( n -- n-4 )
            .global CODE_DEC4
CODE_DEC4:	pop		AL
			pop		AH
			subi	AL, lo8(4)
			sbci	AH, hi8(4)
			push	AH
			push	AL
			rjmp	NEXT


			; ( n1 n2 -- n1+n2 )
            .global CODE_ADD
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
            .global CODE_SUB
CODE_SUB:	pop		BL
			pop		BH

			pop		AL
			pop		AH
			
			sub		AL, BL
			sbc		AH, BH

			push	AH
			push	AL

			rjmp	NEXT


			; ( n -- n*2 )
			.global	CODE_MUL2
CODE_MUL2:	pop		AL
			pop		AH

			lsl		AL
			rol		AH

			push	AH
			push	AL

			rjmp	NEXT


			; ( n -- n/2 )
			.global	CODE_DIV2
CODE_DIV2:	pop		AL
			pop		AH

			asr		AH
			ror		AL

			push	AH
			push	AL

			rjmp	NEXT

			; ( n1 n2 -- n1==n2 )
            .global CODE_EQ
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
            .global CODE_NEQ
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


			; ( addr -- n )
			.global CODE_FETCH
CODE_FETCH:	pop		YL
			pop		YH

			ld		r16, Y+
			ld		r17, Y

			push	r17
			push	r16

			rjmp	NEXT