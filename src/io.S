			#include "global.inc"

			_KEY  = uartGetc
			_EMIT = uartPutc

			.section .noinit
word_ptr:	.word   0
code_ptr:	.word   0
word_buffer:.space  WORD_SIZE

			.text

;================== printVal

			#define prvTmp   r22
			#define prvSign  r23
			#define prvInL   r16
			#define prvInH   r17
			#define prvDivL  r18
			#define prvDivH  r19
			#define prvRem   r22

; printVal([R17:R16])
; uses R18, R19, R20, R21, R22, R23
            .global printVal
printVal:	clr		prvSign
			sbrs	prvInH, 7
			rjmp	prv_3

			ldi		prvSign, 1
			com		prvInH
			neg		prvInL

prv_3:		ldi		ZL, lo8(word_buffer)
			ldi		ZH, hi8(word_buffer)
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


			#define gwChar r16
			#define gwLen  r19


;================== getWord

; word_buffer = getWord()
; R19 = len()
; uses R16, R17, R18, R19, Y, Z
            .global getWord
getWord:	ldi		ZL, lo8(word_buffer)
			ldi		ZH, hi8(word_buffer)
			clr		gwLen
			
gw_start:	rcall	uartGetc
			cpi		gwChar, '\'			; skip comments
			breq	gw_skipcomment
			cpi		gwChar, ' '			; skip spaces
			breq	gw_start

gw_read:	cpi		gwChar, 'a'			; make the word uppercased
			brlo	gw_nolw
			cpi		gwChar, 'z'+1
			brge	gw_nolw
			subi	gwChar, 'a'-'A'
gw_nolw:	st		Z+, gwChar
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

			#define stiSign r15
			#define stiAccL r16
			#define stiAccH r17
			#define stiChar r21
			#define stiMulL r18

; [R17:R16] = strToInt(word_buffer)
; error = 1 if failed
; uses R15, R18, R19, R20, R21, Y
            .global strToInt
strToInt:	ldi		YL, lo8(word_buffer)
			ldi		YH, hi8(word_buffer)
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
