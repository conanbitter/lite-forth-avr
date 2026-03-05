			#include "global.inc"

			.data

			.global line_buffer
			.global	line_end
			.global	line_caret
line_buffer:.space	LINE_SIZE
line_caret:	.byte	0			
line_end:	.byte	0

			.global	word_len
			.global word_buffer
			.type	word_buffer, @object
			.size	word_buffer, WORD_SIZE
word_len:	.byte	0
word_buffer:.space  WORD_SIZE


			.text



;================== printVal
;
; in [R17:R16] - a 16 bit value
;
;==================
			#define prvTmp   r22
			#define prvSign  r23
			#define prvInL   r16
			#define prvInH   r17
			#define prvDivL  r18
			#define prvDivH  r19
			#define prvRem   r22

            .global printVal
printVal:	save	r18, r19, r22, r23
			clr		prvSign
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

prv_4:		rcall	uartSend
			restore	r18, r19, r22, r23
			ret



;================== printValHex
;
; in R16 - an 8 bit value
;
;==================
			#define prhSaved r15
			#define prhChar  r16

			.global	printValHex
printValHex:
			save	r15, r17, ZL, ZH
			mov		prhSaved, prhChar	; save input value

			swap	prhChar				; get first nibble
			andi	prhChar, 0b00001111

			ldi		ZL, lo8(HEX_DIGITS)	; get according char
			ldi		ZH, hi8(HEX_DIGITS)
			add		ZL, prhChar
			clr		r16
			adc		ZH, r16
			lpm		prhChar, Z

			rcall	_EMIT

			mov		prhChar, prhSaved	; restore input value

			andi	prhChar, 0b00001111	; get second nibble

			ldi		ZL, lo8(HEX_DIGITS)	; get according char
			ldi		ZH, hi8(HEX_DIGITS)
			add		ZL, prhChar
			clr		r16
			adc		ZH, r16
			lpm		prhChar, Z

			rcall	_EMIT

			restore	r15, r17, ZL, ZH
			ret

HEX_DIGITS:	.ascii	"0123456789ABCDEF"
			.align	1



;================== _KEY
;
; out R16 - input character
;
;==================
			.global _KEY
_KEY:		save	r17, YL, YH
			lds		r16, line_end		; is line ended?
			tst		r16
			breq	key_notempty
			clr		r16					; line is ended, return zero
			restore	r17, YL, YH
			ret

key_notempty:
			ldi		YL, lo8(line_buffer)
			ldi		YH, hi8(line_buffer)

			lds		r16, line_caret
			clr		r17

			add		YL, r16
			adc		YH, r17

			inc		r16
			sts		line_caret, r16

			ld		r16, Y
			tst		r16
			brne	key_end

			ldi		r17, 1
			sts		line_end, r17

key_end:	restore	r17, YL, YH
			ret



;================== getWord
;
; out word_buffer, word_len
;
;==================
			#define gwChar r16
			#define gwLen  r18

            .global getWord
getWord:	save	r16, r18, ZL, ZH
			ldi		ZL, lo8(word_buffer)
			ldi		ZH, hi8(word_buffer)
			clr		gwLen
			
gw_start:	rcall	_KEY
			cpi		gwChar, '\\'		; skip comments
			breq	gw_skipcomment
			cpi		gwChar, ' '			; skip spaces
			breq	gw_start

gw_read:	cpi		gwChar, ' ' 		; end of the word
			breq	gw_end

			tst		gwChar				; end of the line
			breq	gw_end

			cpi		gwChar, 'a'			; make the word uppercased
			brlo	gw_nolw
			cpi		gwChar, 'z'+1
			brge	gw_nolw

			subi	gwChar, 'a'-'A'

gw_nolw:	st		Z+, gwChar
			inc		gwLen 				; increase size of the word

			cpi		gwLen, WORD_SIZE-1	; word too long
			breq	gw_end

			rcall	_KEY
			rjmp	gw_read

gw_end:		clr		gwChar				; zero termination
			st		Z+, gwChar
			sts		word_len, gwLen		; save length
			restore	r16, r18, ZL, ZH
			ret

gw_skipcomment:
			clr		gwLen
			sts		word_len, gwLen		; save length
			ldi		r16, 1
			sts		line_end, r16
			restore	r16, r18, ZL, ZH
			ret



;================== strToInt
;
; in word_buffer
;
; out [R17:R16] - converted value
;     isError = 1 if failed, otherwise 0
;
;==================
			#define stiSign r15
			#define stiAccL r16
			#define stiAccH r17
			#define stiChar r21
			#define stiMulL r18

             .global strToInt
strToInt:	save	r15, r18, r19, r21, YL, YH
			ldi		YL, lo8(word_buffer)
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

			rcall	mul16_by10u
			movw	stiAccL, stiMulL

			add		stiAccL, stiChar
			clr		stiChar
			adc		stiAccH, stiChar

			rjmp	sti_loop

sti_end:	tst		stiSign
			breq	sti_ret

			neg		stiAccL
			com		stiAccH	

			rjmp	sti_ret

sti_error:	ldi		stiChar, 1
			mov		isError, stiChar
sti_ret:	restore	r15, r18, r19, r21, YL, YH
			ret
