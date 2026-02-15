			.def	prvTmp   = r22
			.def	prvSign  = r23
			.def	prvInL   = r16
			.def	prvInH   = r17
			.def	prvDivL  = r18
			.def	prvDivH  = r19
			.def	prvRem   = r22

; printVal([r17:r16])
; use r18, r19, r20, r21, r22, r23
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