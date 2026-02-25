			#include "m328Pdef.inc"
			#include "global.inc"

			UART_BAUDRATE    = 9600
			UART_BPS         = (F_CPU/16/UART_BAUDRATE)-1

			.text
;================== uartInit

; uartInit()
; uses R16
            .global uartInit
uartInit:	ldi		r16, 0
			sts		line_caret, r16
			
			ldi		r16, 1
			sts		line_end, r16
			
			ldi		r16, lo8(UART_BPS)
			sts		UBRR0L, r16
			
			ldi		r16, hi8(UART_BPS)
			sts		UBRR0H, r16
			
			ldi		r16, (1<<RXEN0)|(1<<TXEN0)
			sts		UCSR0B, r16
			ret


;================== uartInput

; line_buffer = uartInput()
; uses R17, R18, Y
            .global uartInput
uartInput:	ldi		YL, lo8(line_buffer)
			ldi		YH, hi8(line_buffer)

			clr		r16
uartin_loop:
			lds		r17, UCSR0A			; wait for char
			sbrs	r17, RXC0
			rjmp	uartin_loop
			
			lds		r18, UDR0			; read char
			cpi		r18, 0x0D			; is '\n'
			breq	uartin_endloop

#if defined(UART_ECHO) && (UART_ECHO == 1)
uartin_e:	lds		r17, UCSR0A
			sbrs	r17, UDRE0
			rjmp	uartin_e
		
			sts		UDR0, r18			
#endif

			st		Y+, r18
			inc		r16
			cpi		r16, LINE_SIZE-1	; check overflow
			brsh	uartin_endloop
			rjmp	uartin_loop
uartin_endloop:
			clr		r17
			st		Y, r17				; write zero at the end of the line
			sts		line_caret, r17		; reset caret
			sts		line_end, r17		; reset eol

			ret


;================== uartPutc

; uartPutc(R16)
; uses R17
            .global uartPutc
uartPutc:	lds		r17, UCSR0A
			sbrs	r17, UDRE0
			rjmp	uartPutc
			
			sts		UDR0, r16
			ret


;================== uartSendPm

; uartSendPm(Z)
; uses R16, R17
            .global uartSendPm
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
            .global uartSend
uartSend:	ld		r16, Z+
			tst		r16
			breq	uarts_end
			
uarts_wait:	lds		r17, UCSR0A
			sbrs	r17, UDRE0
			rjmp	uarts_wait
			
			sts		UDR0, r16
			rjmp	uartSend
			
uarts_end:	ret
