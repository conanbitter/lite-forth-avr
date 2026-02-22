			.macro  uartMsg msgAddr
			ldi		ZL, lo8(\msgAddr)
			ldi		ZH, hi8(\msgAddr)
			rcall	uartSendPm
			.endm

			.weak uart_buf
			.weak uartInit
			.weak uartGetc
			.weak uartPutc
			.weak uartSendPm
			.weak uartSend