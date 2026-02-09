CODE_DROP:	pop r16
			pop r16
			rjmp NEXT


CODE_SWAP:	pop r16
			pop r17
			pop r18
			pop r19
			push r17
			push r16
			push r19
			push r18
			rjmp NEXT


CODE_DUP:	pop r16
			pop r17
			push r17
			push r16
			push r17
			push r16
			rjmp NEXT