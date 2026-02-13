; ", 0" at the end of the name is for padding
; to even number of bytes

WORD_DROP:	.dw 0
			.db 4, "DROP", 0
DROP:		.dw CODE_DROP


WORD_SWAP:	.dw WORD_DROP
			.db 4, "SWAP", 0
SWAP:		.dw CODE_SWAP


WORD_DUP:	.dw WORD_SWAP
			.db 3, "DUP"
DUP:		.dw CODE_DUP


WORD_OVER:	.dw WORD_DUP
			.db 4, "OVER", 0
OVER:		.dw CODE_OVER


WORD_ROT:	.dw WORD_OVER
			.db 3, "ROT"
ROT:		.dw CODE_ROT


WORD_NROT:	.dw WORD_ROT
			.db 4, "-ROT", 0
NROT:		.dw CODE_NROT


WORD_2DROP:	.dw WORD_NROT
			.db 5, "2DROP"
2DROP:		.dw CODE_2DROP


WORD_2SWAP:	.dw WORD_2DROP
			.db 5, "2SWAP"
2SWAP:		.dw CODE_2SWAP


WORD_2DUP:	.dw WORD_2SWAP
			.db 4, "2DUP", 0
2DUP:		.dw CODE_2DUP


WORD_QDUP:	.dw WORD_2DUP
			.db 4, "?DUP", 0
QDUP:		.dw CODE_QDUP


WORD_INC:	.dw WORD_QDUP
			.db 2, "1+", 0
INC:		.dw CODE_INC


WORD_DEC:	.dw WORD_INC
			.db 2, "1-", 0
DEC:		.dw CODE_DEC


WORD_INC2:	.dw WORD_DEC
			.db 2, "2+", 0
INC2:		.dw CODE_INC2


WORD_DEC2:	.dw WORD_INC2
			.db 2, "2-", 0
DEC2:		.dw CODE_DEC2


WORD_INC4:	.dw WORD_DEC2
			.db 2, "4+", 0
INC4:		.dw CODE_INC4


WORD_DEC4:	.dw WORD_INC4
			.db 2, "4-", 0
DEC4:		.dw CODE_DEC4


WORD_ADD:	.dw WORD_DEC4
			.db 1, "+"
ADD:		.dw CODE_ADD


WORD_SUB:	.dw WORD_ADD
			.db 1, "-"
SUB:		.dw CODE_SUB


WORD_EQ:	.dw WORD_SUB
			.db 1, "="
EQ:			.dw CODE_EQ


WORD_NEQ:	.dw WORD_EQ
			.db 2, "<>", 0
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