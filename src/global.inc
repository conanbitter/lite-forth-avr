			#define isError     r2
			#define isCompiling r3

            RSTACK_SIZE    = 32 * 2
			FLAG_PM        = 0b10000000
			FLAG_IMMEDIATE = 0b10000000
			FLAG_HIDDEN    = 0b00100000
			LENGTH_MASK    = 0b00011111
			WORD_SIZE      = 32

.macro      sendMsg msgAddr
			ldi		ZL, lo8(\msgAddr)
			ldi		ZH, hi8(\msgAddr)
			rcall	uartSendPm
.endm