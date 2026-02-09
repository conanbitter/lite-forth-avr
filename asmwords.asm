WORD_DROP:	.dw 0
			.db 4, "DROP", 0
DROP:		.dw CODE_DROP


WORD_SWAP:	.dw WORD_DROP
			.db 4, "SWAP", 0
SWAP:		.dw CODE_SWAP


WORD_DUP:	.dw WORD_SWAP
			.db 4, "DUP"
DUP:		.dw CODE_DUP

;TODO
;OVER
;ROT
;-ROT
;2DROP
;2SWAP
;2DUP
;?DUP
;1+
;1-
;2+
;2-
;4+
;4-
;+
;-
;*
;=
;<>
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