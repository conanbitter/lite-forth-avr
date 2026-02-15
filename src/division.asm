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
			.def	d10rem8  = r20
			.def	d10multmpL = r20
			.def	d10multmpH = r21
			.def	d10mulres1L = r4
			.def	d10mulres1H = r5
			.def	d10mulres2L = r6
			.def	d10mulres2H = r7

; [r19:r18] = [r17:r16] / 10
; [r20]     = [r17:r16] mod 10
div16_by10u:
			; multiply input by 0xCCCD
			ldi		d10multmpL, 0xCD			
			ldi		d10multmpH, 0xCC

			mul		d10in16L, d10multmpL
			movw	d10mulres1L, r0

			mul		d10in16H, d10multmpL
			add		d10mulres1H, r0
			adc		d10mulres2L, r1

			mul		d10in16L, d10multmpH
			add		d10mulres1H, r0
			adc		d10mulres2L, r1

			mul		d10in16H, d10multmpH
			add		d10mulres2L, r0
			adc		d10mulres2H, r1
			; product now in d10mulres{2H:2L:1H:1L}

			; >> 19 shift (>>16 then >>3)
			mov		d10out16L, d10mulres2L		;todo use d10out16 instead of d10mulres
			mov		d10out16H, d10mulres2H

			lsr		d10out16H
			ror		d10out16L
			lsr		d10out16H
			ror		d10out16L
			lsr		d10out16H
			ror		d10out16L			; r19:r18 = quotient

			; remainder = value − q*10
			movw	r30, d10out16L		; q
			lsl		r30					; q*2
			rol		r31
			lsl		r30 				; q*4
			rol		r31
			add		r30, d10out16L		; q*5
			adc		r31, d10out16H
			lsl		r30					; q*10
			rol		r31

			mov		r20, d10in16L
			sub		r20, r30
			mov		r21, d10in16H
			sbc		r21, r31				; remainder in r20
			ret

; ---------------------------------------
; divu16_by_10_fast
; R5:R4 = value
; R7:R6 = quotient
; R8    = remainder
; Uses only R4–R23 (+ R0,R1 from MUL)
; ---------------------------------------

    ldi  r20,0xCD        ; reciprocal low
    ldi  r21,0xCC        ; reciprocal high

; ---- 16x16 multiply → 32-bit product in r13:r12:r11:r10 ----

    mul  r4,r20          ; LL
    movw r10,r0          ; r11:r10

    mul  r5,r20          ; HL
    add  r11,r0
    adc  r12,r1

    mul  r4,r21          ; LH
    add  r11,r0
    adc  r12,r1

    mul  r5,r21          ; HH
    add  r12,r0
    adc  r13,r1
    clr  r1              ; ABI rule

; product = r13:r12:r11:r10

; ---- >>19  (>>16 then >>3) ----

    mov  r6,r12
    mov  r7,r13

    lsr  r7
    ror  r6
    lsr  r7
    ror  r6
    lsr  r7
    ror  r6

; quotient now r7:r6

; ---- compute q*10 in r15:r14 ----

    movw r14,r6          ; q
    lsl  r14             ; *2
    rol  r15
    lsl  r14             ; *4
    rol  r15
    add  r14,r6          ; *5
    adc  r15,r7
    lsl  r14             ; *10
    rol  r15

; ---- remainder = value − q*10 ----

    mov  r8,r4
    sub  r8,r14
    mov  r9,r5
    sbc  r9,r15
    ; r8 = remainder (0..9)

    ret