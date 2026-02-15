			.equ	_KEY  = uartGetc
			.equ	_EMIT = uartPutc

;================== printVal

			.def	prvTmp   = r22
			.def	prvSign  = r23
			.def	prvInL   = r16
			.def	prvInH   = r17
			.def	prvDivL  = r18
			.def	prvDivH  = r19
			.def	prvRem   = r22

; printVal([R17:R16])
; uses R18, R19, R20, R21, R22, R23
printVal:	clr		prvSign
			sbrs	prvInH, 7
			rjmp	prv_3

			ldi		prvSign, 1
			com		prvInH
			neg		prvInL

prv_3:		ldi		ZL, low(word_buffer)
			ldi		ZH, high(word_buffer)
			adiw	ZL, 7
			clr		prvTmp
			st		-Z, prvTmp
			rjmp	prv_2
prv_1:		movw	prvInL, prvDivL
prv_2:		rcall	div16_by10u
			subi	prvRem, -48		; add '0'
			st		-Z, prvRem
			tst		prvDivL
			brne	prv_1
			tst		prvDivH
			brne	prv_1
			
			tst		prvSign
			breq	prv_4
			ldi		prvTmp, '-'
			st		-Z, prvTmp

prv_4:		rcall uartSend
			ret


			.def	gwChar = r16
			.def	gwLen  = r19


;================== getWord

; word_buffer = getWord()
; R19 = len()
; uses R16, R17, R18, R19, Y, Z
getWord:	ldi		ZL, low(word_buffer)
			ldi		ZH, high(word_buffer)
			clr		gwLen
			
gw_start:	rcall	uartGetc
			cpi		gwChar, '\'			; skip comments
			breq	gw_skipcomment
			cpi		gwChar, ' '			; skip spaces
			breq	gw_start

gw_read:	st		Z+, gwChar
			inc		gwLen 				; size of the word
			rcall	uartGetc
			cpi		gwChar, ' ' 		; end of the word
			breq	gw_end
			cpi		gwChar, 0x0D		; end of the line
			breq	gw_end
			cpi		gwLen, WORD_SIZE-1	; word too long
			breq	gw_end
			rjmp	gw_read

gw_end:		clr		gwChar				; zero termination
			st		Z+, gwChar
			ret

gw_skipcomment:
			rcall	uartGetc
			cpi		gwChar, 0x0D 		; '\n'
			brne	gw_skipcomment
			rjmp	gw_start


;================== strToInt

			.def	stiSign = r15
			.def	stiAccL = r16
			.def	stiAccH = r17
			.def	stiChar = r21
			.def	stiMulL = r18

; [R17:R16] = strToInt(word_buffer)
; error = 1 if failed
; uses R15, R18, R19, R20, R21, Y
strToInt:	ldi		YL, low(word_buffer)
			ldi		YH, high(word_buffer)
			clr		isError
			clr		stiSign
			clr		stiAccL
			clr		stiAccH

			ld		stiChar, Y			; check leading '-'
			cpi		stiChar, '-'
			brne	sti_loop
			inc		stiSign
			adiw	YL, 1

sti_loop:	ld		stiChar, Y+
			tst		stiChar
			breq	sti_end

			cpi		stiChar, '9'+1
			brsh	sti_error			; not a digit
			subi	stiChar, '0'
			brlo	sti_error			; not a digit

			call	mul16_by10u
			movw	stiAccL, stiMulL

			add		stiAccL, stiChar
			clr		stiChar
			adc		stiAccH, stiChar

			rjmp	sti_loop

sti_end:	tst		stiSign
			breq	sti_ret

			neg		stiAccL
			com		stiAccH	

sti_ret:	ret

sti_error:	ldi		stiChar, 1
			mov		isError, stiChar
			ret
