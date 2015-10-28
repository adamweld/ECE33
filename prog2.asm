; Adam Weld
; Program 2
;
   bdos     equ    5           ; CP/M function call address
   boot     equ    0           ; address to get back to CP/M
   conin    equ    1           ; keyboard read function number
   conout   equ    2           ; console output function number
   sprint   equ    9           ; string print function number
   cr       equ    0Dh         ; value of ASCII code of <CR>
   lf       equ    0Ah         ; value of ASCII code of line feed
;
			org    	100h        ; standard origin for CP/M
			lxi   	sp,sp0      ; initialize stack pointer
			mvi   	c,sprint    ; set bdos for printing message
      lxi   	d,messp     ; address of welcome message
			call  	bdos        ; print welcome message
			lxi 	h,buffs		; input counter to correct buffer
			call  	input		; take sentence input
			lxi   	d,messw		; print word prompt
			call	bdos
			lxi		h,buffw		; set buffer location for word
			call 	input		; take string input using subroutine
			lxi 	d,messn		; print number prompt
			call 	bdos
			lxi		h,0			; set up input subroutine for number input
			call  	input		; insertion number is now in L
			mov		b,l			; save insertion number in B
			lxi 	d,messd		; set print pointer to 'done' message
			call 	bdos		; print message
			lxi 	h,buffs		; set memory pointer to beginning of sentence
			mvi		c,conout	; set CP/M for single character print
			mov 	a,b			; these two lines check if b is 0
			cpi		0
			jz		cap     ; case that b is 0 - skip first print loop
r0:		mov		a,mem		; pull character of sentence from memory
			cpi		'.'			; compare with period
			jz		f0			; jump out of loop when we hit a period
      cpi   '?'     ; do the same for questionmark
      jz    f0
			mov		e,a			; these three lines print the character to screen and increment
			call 	bdos
			inx		h
			cpi		' '			; compare to ascii space
			jnz		r0
			dcr		b			; decrease space counter
			jnz		r0
cap:  mov   a,m     ; pull first sentence character from buff
      cpi   91      ; check if it is capitalized
      jp    cap1
      adi   20H     ; make it lower case if so
      mov   m,a     ; and store to mem
cap1: lda   buffw   ; load word buffer
      cpi   91      ; check if capitalized
      jc    prnt
      sui   20H     ; if not capitalize
      sta   buffw
prnt:	mvi		c,sprint	; next three lines print the word from buffer
			lxi		d,buffw
			call 	bdos
			mvi		c,conout	; next three lines print a space
			mvi		e,' '
			call	bdos
re:		mov		a,m
			cpi		'.'			; compare with period
			jz		f0			; when we hit a period jump out of loop
      cpi   '?'     ; do the same for questionmark
      jz    f0
			mov		e,a			; copy character to e for printing
			call	bdos		; call print function
			inx		h			; increment character pointer
			jmp		re
f0:	  push  psw     ; store A value for safekeeping
      mvi		a,0
			sub		b			; check if b is zeroed
			jz		f1			; if it is, skip to printing the period
			mvi		e,' '		; these two lines print a space before the word
			call	bdos
			mvi		c,sprint	; if the word hasn't been printed, print the word now
			lxi		d,buffw		; set pointer to address of word
			call 	bdos		; call print function
			mvi		c,conout	; next three lines print a period
f1:		pop   psw     ; pop A to end sentence
      mov   e,a
			call	bdos
			jmp 	boot		; return to start of program
;
;	input subroutine
; 	takes a string input from user and stores it in memory location, OR number input into register
;	input: memory address in HL pair; if HL == 0 then take number input into register L
;	output: memory starting at HL is overwritten, HL is modified
;	destroys HL, A, BC
; 	stack size: 8
;
input:	push	psw			; push all destroyed registers
			push	b
			mvi 	c,conin
			mov		a,h			; moves H to A
			cpi		0			; check if H is 0 (input switch)
			jnz    	redo		; if not take string input
			call	bdos		; take input character
			sui 	'0'
			mov		l,a			; store current value in L
			add 	a			; doubles input (pre-emptive for case with 2 digits)
			mov		h,a			; store doubled value in H
			call	bdos		; next input
			cpi 	cr			; check if CR
			jz		done		; if single char input, we are done
			sui		'0'
			mov		l,a			; second input is 1s place
			mov		a,h			; bring doubled value back to A
			add		a			; A has 4x
			add		a			; A has 8x
			add		h			; A has 10x (10s place)
			add		l			; add 1s and 1s
			call 	bdos		; user SHOULD enter CR here; any input does the same thing
			jmp		done
redo:	call 	bdos		; take input character
			cpi 	cr			; check if CR
			jz 		d1	  	; if so jump done
			mov		m,a			; if not move to mem
			inx		h			  ; increase pointer
			jmp		redo		; take next character
d1:   mvi   a,'$'   ; save $ after input
      mov   m,a
done: pop 	b
			pop 	psw			; pop destroyed registers
			ret					  ; return
messp: db   '    The ENCHANCED Magical sentence Discombobulator'
       db   LF, CR, 'Please enter a sentence: $'
messw: db	  LF, CR, 'Now enter a word: $'
messn: db 	LF, CR, 'To insert after: $'
messd: db		LF, LF, CR, 'Discombobulator result: $'
buffs: ds		41
buffw: ds		20			; word buffer
			ds		16			; space for stack
			sp0 	equ $		; stack address
			end					  ; ends assembler
