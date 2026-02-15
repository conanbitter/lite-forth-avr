;================== uartInit

; uartInit()
; uses R16
uartInit:	ldi		r16, 0
			sts		uart_caret, r16
			
			ldi		r16, 1
			sts		uart_empty, r16
			
			ldi		r16, low(UART_BPS)
			sts		UBRR0L, r16
			
			ldi		r16, high(UART_BPS)
			sts		UBRR0H, r16
			
			ldi		r16, (1<<RXEN0)|(1<<TXEN0)
			sts		UCSR0B, r16
			ret


;================== uartGetc

; R16 = getc()
; uses R17, R18, Y
uartGetc:	ldi		YL, low(uart_buf)
			ldi		YH, high(uart_buf)
			
			lds		r16, uart_empty
			tst		r16
			breq	uartgc_not_empty
			
			; buffer is empty, load new string
			clr		r16
uartgc_loop:
			lds		r17, UCSR0A			; wait for char
			sbrs	r17, RXC0
			rjmp	uartgc_loop
			
			lds		r18, UDR0
			st		Y+, r18
			inc		r16
			cpi		r18, 0x0D			; is '\n'
			breq	uartgc_endloop
			cpi		r16, UART_BUFFER_SIZE-1
			brsh	uartgc_endloop
			rjmp	uartgc_loop
uartgc_endloop:
			clr		r17
			st		Y, r17
			sts		uart_empty, r17
			ldi		YL, low(uart_buf)
			ldi		YH, high(uart_buf)
			rjmp	uartgc_load_next
			
			; buffer is not empty, get next char
uartgc_not_empty:
			lds		r17, uart_caret
			clr		r18
			add		YL, r17
			adc		YH, r18
			
uartgc_load_next:
			ld		r16, Y+
			ld		r18, Y
			tst		r18
			breq	uartgc_became_empty
			inc		r17
			sts		uart_caret, r17
			ret
uartgc_became_empty:
			ldi		r18, 1
			sts		uart_empty, r18			
			ret


;================== uartPutc

; uartPutc(R16)
; uses R17
uartPutc:	lds		r17, UCSR0A
			sbrs	r17, UDRE0
			rjmp	uartPutC
			
			sts		UDR0, r16
			ret


;================== uartSendPm

; uartSendPm(Z)
; uses R16, R17
uartSendPm:	lpm		r16, Z+
			tst		r16
			breq	uartm_end
			
uartm_wait:	lds		r17, UCSR0A
			sbrs	r17, UDRE0
			rjmp	uartm_wait
			
			sts		UDR0, r16
			rjmp	uartSendPm
			
uartm_end:	ret


;================== uartSend

; uartSend(Z)
; uses R16, R17
uartSend:	ld		r16, Z+
			tst		r16
			breq	uarts_end
			
uarts_wait:	lds		r17, UCSR0A
			sbrs	r17, UDRE0
			rjmp	uarts_wait
			
			sts		UDR0, r16
			rjmp	uartSend
			
uarts_end:	ret
