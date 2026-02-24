;=========== MACROS

			.macro  asmword name, text, flags=0

			.global	WORD_\name
			.type	WORD_\name ,@object
			.align	1
WORD_\name :.word	prev_word
			.set	prev_word, WORD_\name
			.byte	(2f - 1f) | \flags
1:			.ascii	"\text"
2:			.ifeq (2b - 1b) % 2
			.byte 2b - 1b
			.else
			.byte 0
			.byte 2b - 1b + 1
			.endif
            .global	\name
			.type	\name ,@object
\name :		.word	pm(CODE_\name)

			.endm


			.set prev_word, 0

			.text

;=========== ASMWORDS

            asmword FIND,  "FIND"
			asmword TCFA,  ">CFA"
			asmword KEY,   "KEY"
			asmword EMIT,  "EMIT"
			asmword WORD,  "WORD"
			asmword DROP,  "DROP"
			asmword SWAP,  "SWAP"
			asmword DUP,   "DUP"
			asmword OVER,  "OVER"
			asmword ROT,   "ROT"
			asmword NROT,  "-ROT"
			asmword DROP2, "2DROP"
			asmword SWAP2, "2SWAP"
			asmword DUP2,  "2DUP"
			asmword QDUP,  "?DUP"
			asmword INC,   "1+"
			asmword DEC,   "1-"
			asmword INC2,  "2+"
			asmword DEC2,  "2-"
			asmword INC4,  "4+"
			asmword DEC4,  "4-"
			asmword ADD,   "+"
			asmword SUB,   "-"
			asmword EQ,    "="
			asmword NEQ,   "<>"


			.global LAST_CORE
			.type	LAST_CORE, @object
LAST_CORE:	.word	prev_word