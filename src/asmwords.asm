; format:
; u16      pointer to previous word
; u8       len(name) and flags
; u8[1-31] name
; u8       len(name) + padding
; u16      codeword_pointer

; name is padded with ", 0" to even number of bytes

			.equ LAST_CORE = WORD_NEQ

WORD_DROP:	.dw	0
			.db 4, "DROP", 4
DROP:		.dw CODE_DROP


WORD_SWAP:	.dw WORD_DROP *2
			.db 4, "SWAP", 4
SWAP:		.dw CODE_SWAP


WORD_DUP:	.dw WORD_SWAP *2
			.db 3, "DUP", 0, 4
DUP:		.dw CODE_DUP


WORD_OVER:	.dw WORD_DUP *2
			.db 4, "OVER", 4
OVER:		.dw CODE_OVER


WORD_ROT:	.dw WORD_OVER *2
			.db 3, "ROT", 0, 4
ROT:		.dw CODE_ROT


WORD_NROT:	.dw WORD_ROT *2
			.db 4, "-ROT", 4
NROT:		.dw CODE_NROT


WORD_2DROP:	.dw WORD_NROT *2
			.db 5, "2DROP", 0, 6
2DROP:		.dw CODE_2DROP


WORD_2SWAP:	.dw WORD_2DROP *2
			.db 5, "2SWAP", 0, 6
2SWAP:		.dw CODE_2SWAP


WORD_2DUP:	.dw WORD_2SWAP *2
			.db 4, "2DUP", 4
2DUP:		.dw CODE_2DUP


WORD_QDUP:	.dw WORD_2DUP *2
			.db 4, "?DUP", 4
QDUP:		.dw CODE_QDUP


WORD_INC:	.dw WORD_QDUP *2
			.db 2, "1+", 2
INC:		.dw CODE_INC


WORD_DEC:	.dw WORD_INC *2
			.db 2, "1-", 2
DEC:		.dw CODE_DEC


WORD_INC2:	.dw WORD_DEC *2
			.db 2, "2+", 2
INC2:		.dw CODE_INC2


WORD_DEC2:	.dw WORD_INC2 *2
			.db 2, "2-", 2
DEC2:		.dw CODE_DEC2


WORD_INC4:	.dw WORD_DEC2 *2
			.db 2, "4+", 2
INC4:		.dw CODE_INC4


WORD_DEC4:	.dw WORD_INC4 *2
			.db 2, "4-", 2
DEC4:		.dw CODE_DEC4


WORD_ADD:	.dw WORD_DEC4 *2
			.db 1, "+", 0, 2
ADD:		.dw CODE_ADD


WORD_SUB:	.dw WORD_ADD *2
			.db 1, "-", 0, 2
SUB:		.dw CODE_SUB


WORD_EQ:	.dw WORD_SUB *2
			.db 1, "=", 0, 2
EQ:			.dw CODE_EQ


WORD_NEQ:	.dw WORD_EQ *2
			.db 2, "<>", 2
NEQ:		.dw CODE_NEQ

;TODO
;*
;<
;>
;<=
;>=
;0=
;0<>
;0<
;0>
;0<=
;0>=
;AND
;OR
;NOT/INVERT
;LIT
;!
;@
;+!
;-!
;C!
;C@
;C@C!
;CMOVE

;>R
;R>
;RSP@
;RSP!
;RDROP
;DSP@
;DSP!