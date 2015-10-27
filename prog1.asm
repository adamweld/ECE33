;	Adam Weld 10.13.2015
;	This is the assembly program for HW assignment 1 in ECE33
;	Read 8 nonnegative numbers between 0 and 255
;	Print how many are smaller than 66, how many are between 67-166 (inclusive)
;   , and how many are larger than 166.
;	No user error checking needed
;
   bdos      equ    5           ; CP/M function call address
   boot      equ    0           ; address to get back to CP/M
   conin     equ    1           ; keyboard read function number
   conout    equ    2           ; console output function number
   sprint    equ    9           ; string print function number
   cr        equ    0Dh         ; value of ASCII code of <CR>
   lf        equ    0Ah         ; value of ASCII code of line feed
;		
			org    100h         ; standard origin for CP/M
			lxi    sp,sp0       ; initialize stack pointer
			mvi    c,sprint     ; set bdos for printing message
			mvi    b, 8			; counter for 8 inputs
			lxi    d,mess1      ; address of welcome message
			call   bdos         ; print welcome message
			lxi    d,mess2		; address of prompt
			mvi    a,'0'		; stores ASCII 0 in A register
			sta    nsmall
			sta    nmed
			sta    nlrg			; re writes ASCII 0 character to memory locations to reset values
	inpt:	call   bdos			; print prompt
			call   take3		; take the input and return a binary value (in A)
			call   eval			; increment relevant memory buffer (small, med, or large)
			dcr    b			; decrement input counter
			jnz    inpt			; if not, continue taking inputs
								; program is done, we will print results now
			lxi    d,mess3		; address of results pointer
			call   bdos			; print results
			jmp	   boot			; go back to CP/M boot			
;
; 	take3 subroutine
;	takes a keyboard input of up to 255, returns a binary number
;	input: none
;	output: 1-bit value in A register
;	destroys BC and DE registers
;	stack size: 12
	take3:	push   b
			push   d			; store original values of destroyed registers
			mvi    c,conin		; set bdos to take input
			mvi	   b,0			; places counter in B
			lxi    d,0			; store 0 in DE pair
	r0:		call   bdos 		; take input
			cpi    cr			; check if user has entered CR
			jz     r1			; if so go to next section of subroutine
			sui	   '0'			; go from ASCII value to number value
			inr    b			; increment places counter (B)
			push   psw			; save input value in stack
			jmp    r0			; take another character
	r1:		pop    psw			; pull the first value from stack
			dcr	   b			; decrement places counter
			jz     t3done		; if it's at zero, finish subroutine
			mov    d,a			; store 1s place in D register
			pop    psw			; pop 10s place value
			call   ti10			; this is 10s place so we multiply by 10
			dcr    b			; decrement places counter
			jz     t3done		; check for zero, if so go to done		
			mov	   e,a			; store 10s place in E register
			pop    psw			; pull 100s place value from stack
			call   ti10
			call   ti10			; multiply by 100
	t3done:	add    e			; add 10s place (if initialized)
			add    d			; add 1s place (if initialized)
			pop	   d
			pop    b			; restore original register values
			ret
;
; 	eval subroutine
;	takes a 1-bit number and determins if [0,67), [67,166], or (166,255]
;	input: A register
;	output: increments either nsmall, nmed, or nlrg memory location
;	destroys A, HL registers
;	stack size: 4
	eval:	push   psw			; store PSW
			push   h			; store HL pair
			cpi    166			; compare 166
			jz	   med			; edge case that number equals 166
			jnc	   lrg			; number is greater than 166
			cpi	   67			; compare 67
			jnc     med			; number is between 67 and 166
			lxi    h,nsmall		; number is smaller than 67; load small address for incrementing
			jmp    evdone		; finish eval
	med:	lxi    h,nmed		; load med address for incrementing
			jmp    evdone
	lrg:	lxi    h,nlrg		; load med address for incrementing
	evdone:	mov    a,m			; move memmory value to A
			adi    1			; increment
			mov    m,a			; store back in memory
			pop	   h			; return overwritten registers to their original values
			pop    psw			
			ret
;
;	ti10 subrouting
;	multiplies a 1-bit number by 10, no overflow checking
;	input: A register
;	output: A register
;	destroys B register
;	stack size: 2
	ti10:	push b				; store value of B in stack
			add a				; double A
			mov b,a				; move A to B
			add a
			add a				; A is now 8x original value
			add b				; A is now 8x + 2x = 10x original value
			pop b				; return B to original value
			ret					; return to main function
;
	mess1:	db 'The Range Finder', LF, CR, 'Classify eight numbers!$'
	mess2:	db LF, LF, CR, 'Type a number [0,255]: $'
	mess3:	db 'Small numbers: '
	nsmall:	db '0'				; will be filled with number of small entries
			db '    Medium:  '
	nmed:	db '0'				; will be filled with number of medium entries
			db '    Large:  '
	nlrg:	db '0'				; will be filled with number of large entries
			db '$'				; ends mess3 bdos call
			ds 30				; space for stack
			sp0 equ $			; stack address
			end					; ends assembler