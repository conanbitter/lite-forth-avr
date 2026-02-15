			.equ	F_CPU = 16000000
			.equ	UART_BUFFER_SIZE = 80
			.equ	UART_BAUDRATE    = 9600
			.equ	UART_BPS         = (F_CPU/16/UART_BAUDRATE)-1

uart_buf:	.byte	UART_BUFFER_SIZE
uart_caret:	.byte	1
uart_empty: .byte	1

; uartMsg(msg)
            .macro  uartMsg
            ldi		ZL, low(@0*2)
			ldi		ZH, high(@0*2)
			rcall	uartSendPm
            .endm

; uartStr(msg)
            .macro  uartStr
            ldi		ZL, low(@0*2)
			ldi		ZH, high(@0*2)
			rcall	uartSend
            .endm