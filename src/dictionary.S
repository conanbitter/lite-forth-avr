			#include "global.inc"

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



			.macro  varword name, text

			.global	WORD_\name
			.type	WORD_\name ,@object
			.align	1
WORD_\name :.word	prev_word
			.set	prev_word, WORD_\name
			.byte	2f - 1f
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
CODE_\name:	ldi		r16, hi8(VAR_\name)
			push	r16
			ldi		r16, lo8(VAR_\name)
			push	r16
			rjmp	NEXT

			.endm



			.macro  constword name, text, value

			.global	WORD_\name
			.type	WORD_\name ,@object
			.align	1
WORD_\name :.word	prev_word
			.set	prev_word, WORD_\name
			.byte	2f - 1f
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
CODE_\name:	ldi		r16, hi8(\value)
			push	r16
			ldi		r16, lo8(\value)
			push	r16
			rjmp	NEXT

			.endm			



			.macro	pword name arg
			.word	\name + FLAG_PM16
			.ifnb	\arg
			.word	\arg
			.endif
			.endm


			.macro	pconst arg
			.word	LIT + FLAG_PM16
			.word	\arg
			.endm


			.macro	pbr arg
			.word	BRANCH + FLAG_PM16
			.word	\arg - . - 2
			.endm


			.macro	pzbr arg
			.word	ZBRANCH + FLAG_PM16
			.word	\arg - . - 2
			.endm


			.set prev_word, 0

			.text

;=========== ASMWORDS

            asmword	CREATE,  "CREATE"
			asmword	COMMA,   ","
			asmword	LBRAC,   "["
			asmword	RBRAC,   "]"
			asmword	PARSE,   "PARSE"
			asmword QUERY,   "QUERY"
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
			asmword	ERRTST,  "ERRTST"
			asmword	ERROR,   "ERROR"
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
			asmword	CR,      "CR"
			asmword FETCH,   "@"

			varword ERRCODE, "ERRCODE"
			varword STATE, "STATE"
			varword HERE, "HERE"
			varword LATEST, "LATEST"

			constword GETDOCOL, "DOCOL", pm(CODE_DOCOL)

			forthword INTERPRET, "INTERPRET"
1:			pword	PARSE
			pword	ERRCODE
			pword	FETCH
			pword	QDUP
			pzbr	1b
			pword	ERRTST
			pword	EXIT

			forthword QUIT, "QUIT"
1:			pword	QUERY
			pword	INTERPRET
			pword	CR
			pbr		1b

			forthword COLON, ":"
			pword	CREATE
			pconst	pm(CODE_DOCOL)
			pword	COMMA
			;make hidden
			pword	RBRAC
			pword	EXIT

			forthword SEMICOLON, ";"
			pconst	EXIT + FLAG_PM16
			pword	COMMA
			;remove hidden
			pword	LBRAC
			pword	EXIT

/*
			forthword DOUBLE, "DOUBLE"
			pword	DUP
			pword	ADD
			pword	EXIT

			forthword ADDTHREE, "ADD3"
			pconst	3
			pword	ADD
			pword	EXIT

			forthword BRTST, "BRTST"
1:			pconst	4
			pword	DOT
			pbr		1b
			pword	EXIT

			forthword ZBRTST, "BRTST0"
			pconst	11
1:			pword	DEC
			pword	DUP
			pword	DOT
			pword	DUP
			pzbr	2f
			pbr		1b
2:			pword	EXIT*/

			.global LAST_CORE
			.type	LAST_CORE, @object
LAST_CORE:	.word	prev_word