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



			.macro  forthword name, text, flags=0

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
\name :		.word	pm(CODE_DOCOL)

			.endm


			.set prev_word, 0

			.text

;=========== ASMWORDS

            asmword	EXIT,    "EXIT"
			asmword FIND,    "FIND"
			asmword TCFA,    ">CFA"
			asmword KEY,     "KEY"
			asmword EMIT,    "EMIT"
			asmword	DOT,     "."
			asmword	PSTACK,  ".S"
			asmword WORD,    "WORD"
			asmword LIT,     "LIT"
			asmword	BRANCH,  "BRANCH"
			asmword ZBRANCH, "0BRANCH"
			asmword DROP,    "DROP"
			asmword SWAP,    "SWAP"
			asmword DUP,     "DUP"
			asmword OVER,    "OVER"
			asmword ROT,     "ROT"
			asmword NROT,    "-ROT"
			asmword DROP2,   "2DROP"
			asmword SWAP2,   "2SWAP"
			asmword DUP2,    "2DUP"
			asmword QDUP,    "?DUP"
			asmword INC,     "1+"
			asmword DEC,     "1-"
			asmword INC2,    "2+"
			asmword DEC2,    "2-"
			asmword INC4,    "4+"
			asmword DEC4,    "4-"
			asmword ADD,     "+"
			asmword SUB,     "-"
			asmword EQ,      "="
			asmword NEQ,     "<>"

			forthword DOUBLE, "DOUBLE"
			.word	DUP
			.word	ADD
			.word	EXIT

			forthword ADDTHREE, "ADD3"
			.word	LIT
			.word	3
			.word	ADD
			.word	EXIT

			forthword BRTST, "BRTST"
			.word	LIT
			.word	4
			.word	DOT
			.word	BRANCH
			.word	-10
			.word	EXIT

			forthword ZBRTST, "BRTST0"
			.word	LIT
			.word	11
			.word	DEC
			.word	DUP
			.word	DOT
			.word	DUP
			.word	ZBRANCH
			.word	4
			.word	BRANCH
			.word	-16
			.word	EXIT

			.global LAST_CORE
			.type	LAST_CORE, @object
LAST_CORE:	.word	prev_word