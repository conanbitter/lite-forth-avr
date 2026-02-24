			.macro  asmword name, text, flags=0

			.global	WORD_\name
			.align	1
WORD_\name:	.word	LAST_CORE
			.set	LAST_CORE, WORD_\name
			.byte	(2f - 1f) | \flags
1:			.ascii	"\text"
2:			.ifeq (2b - 1b) % 2
			.byte 2b - 1b
			.else
			.byte 0
			.byte 2b - 1b + 1
			.endif
            .global	\name
\name:		.word	pm(CODE_\name)

			.endm


            
			.global LAST_CORE
			.set LAST_CORE, 0

			.text

			.align  1
WORD_FIND:	.word	0
			.byte 4
			.ascii "FIND"
			.byte 4
FIND:		.word CODE_FIND

            asmword SWAP, "SWAP"
			asmword DROP, "DROP"
			asmword DUP, "DUP"

last:		.word	LAST_CORE