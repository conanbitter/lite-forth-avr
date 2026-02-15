			.def	drem16uL = r14
			.def	drem16uH = r15
			.def	dres16uL = r16
			.def	dres16uH = r17
			.def	dd16uL   = r16
			.def	dd16uH   = r17
			.def	dv16uL   = r18
			.def	dv16uH   = r19
			.def	dcnt16u  = r20

; [r17:r16] = [r17:r16] / [r19:r18]
; [r15:r14] = [r17:r16] mod [r19:r18]
div16u:		clr		drem16uL			; clear remainder Low byte
			sub		drem16uH, drem16uH	; clear remainder High byte and	carry
			ldi		dcnt16u, 17			; init loop counter
d16u_1:		rol		dd16uL				; shift left dividend
			rol		dd16uH
			dec		dcnt16u				; decrement counter
			brne	d16u_2				; if done
			ret							; return
d16u_2:		rol		drem16uL			; shift dividend into remainder
			rol		drem16uH
			sub		drem16uL,dv16uL		; remainder = remainder - divisor
			sbc		drem16uH,dv16uH
			brcc	d16u_3				; if result negative
			add		drem16uL,dv16uL		; restore	remainder
			adc		drem16uH,dv16uH
			clc							; clear carry to be shifted into result
			rjmp	d16u_1				; else
d16u_3:		sec							; set carry to be shifted into result
			rjmp	d16u_1



			.def	d16s     = r13	; sign register
			.def	drem16sL = r14	; remainder low byte
			.def	drem16sH = r15	; remainder high byte
			.def	dres16sL = r16	; result low byte
			.def	dres16sH = r17	; result high byte
			.def	dd16sL   = r16	; dividend low byte
			.def	dd16sH   = r17	; dividend high byte
			.def	dv16sL   = r18	; divisor low byte
			.def	dv16sH   = r19	; divisor high byte
			.def	dcnt16s  = r20	; loop counter


div16s:		mov		d16s, dd16sH		; move dividend High to sign register
			eor		d16s, dv16sH		; xor divisor High with sign register
			sbrs	dd16sH, 7			; if MSB in dividend set
			rjmp	d16s_1
			com		dd16sH				; change sign of dividend
			com		dd16sL
			subi	dd16sL, low(-1)
			sbci	dd16sL, high(-1)
d16s_1:		sbrs	dv16sH, 7			; if MSB in divisor set
			rjmp	d16s_2
			com		dv16sH				; change sign of divisor
			com		dv16sL
			subi	dv16sL, low(-1)
			sbci	dv16sH, high(-1)
d16s_2:		clr		drem16sL			; clear remainder Low byte
			sub		drem16sH,drem16sH	; clear remainder High byte and carry
			ldi		dcnt16s, 17			; init loop counter

d16s_3:		rol		dd16sL				; shift left dividend
			rol		dd16sH
			dec		dcnt16s				; decrement counter
			brne	d16s_5				; if done
			sbrs	d16s, 7				; if MSB in sign register set
			rjmp	d16s_4
			com		dres16sH			; change sign of result
			com		dres16sL
			subi	dres16sL, low(-1)
			sbci	dres16sH, high(-1)
d16s_4:		ret							; return
d16s_5:		rol		drem16sL			; shift dividend into remainder
			rol		drem16sH
			sub		drem16sL,dv16sL		; remainder = remainder - divisor
			sbc		drem16sH,dv16sH		;
			brcc	d16s_6				; if result negative
			add		drem16sL,dv16sL		; restore remainder
			adc		drem16sH,dv16sH
			clc							; clear carry to be shifted into result
			rjmp	d16s_3				; else
d16s_6:		sec							; set carry to be shifted into result
			rjmp	d16s_3


			.def	d10in16L  = r16
			.def	d10in16H  = r17
			.def	d10out16L = r18
			.def	d10out16H = r19
			.def	d10tmpL = r20
			.def	d10tmpH = r21
			.def	d10rem = r15

; [r19:r18] = [r17:r16] / 10
; [r15]     = [r17:r16] mod 10
; use R20, R21
div16_by10u:
			; RES = (IN * 0xCCCD) >> 16
			ldi		d10tmpL, low(0xCCCD)
			ldi		d10tmpH, high(0xCCCD)

			clr		d10out16H

			mul		d10in16L, d10tmpL
			mov		d10out16L, r1

			mul		d10in16L, d10tmpH
			add		d10out16L, r0
			adc		d10out16H, r1

			mul		d10in16H, d10tmpL
			add		d10out16L, r0
			adc		d10out16H, r1

			mov		d10out16L, d10out16H
			clr		d10out16H
			adc		d10out16H, d10out16H

			mul		d10in16H, d10tmpH
			add		d10out16L, r0
			adc		d10out16H, r1

			; RES >> 3
			lsr		d10out16H
			ror		d10out16L

			lsr		d10out16H
			ror		d10out16L

			lsr		d10out16H
			ror		d10out16L

			; REM = IN - RES * 10 (only low byte)
			mov		d10tmpL, d10out16L	; TMP = RES
			lsl		d10tmpL				; TMP * 2
			lsl		d10tmpL 			; TMP * 4
			add		d10tmpL, d10out16L	; TMP * 5
			lsl		d10tmpL				; q*10

			mov		d10rem, d10in16L
			sub		d10rem, d10tmpL
    		
			ret