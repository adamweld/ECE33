; Adam Weld
; Program 4
; Simple Calculator
;
      bdos     equ    5         ; CP/M function call address
      boot     equ    0         ; address to get back to CP/M
      conin    equ    1         ; keyboard read function number
      conout   equ    2         ; console output function number
      sprint   equ    9         ; string print function number
      cr       equ    0Dh       ; value of ASCII code of <CR>
      lf       equ    0Ah       ; value of ASCII code of line feed


      org   100h                ; assembler start
      lxi   sp,sp0              ; initialize stack pointer
      mvi   c,sprint            ; set CP/M register to sprint output 
      lxi   d,m0                ; load address of message 0
      call  bdos                ; print message
      mvi   c,conout            ; prepare for character output
r0:   mvi   e,lf 
      call  bdos
      mvi   e,cr
      call  bdos
      mvi   e,'>'
      call  bdos
      call  bdos                ; print both >>
      call  inpt                ; take user input
      cpi   '+'
      jz    add
      cpi   cr
      jz    d0
sub:  mov   a,e
      sub   l
      mov   l,a
      mov   a,d
      sbb   h
      mov   h,a
      call  prnt
      jmp   r0
add:  dad   d                   ; add contents of DE to HL
      call  prnt
      jmp   r0
d0:   mvi   c,sprint
      lxi   d,m1
      call  bdos
      jmp   boot                ; end program


; input subroutine
; takes user input numbers, ignores other characters
; input: keyboard [0-9]
; output: first input in DE, second in HL, passes through +,-, or CR in A 
; destroys: PSW, BC, DE, HL
; stack size: 10

inpt: push  b                   ; push destroyed registers
      lxi   h,0                 ; zero HL pair
      mvi   a,0
      mvi   c,conin             ; set CP/M register for input
ir0:  call  bdos
      cpi   cr                  ; check if done
      jz    i2                  
      cpi   '+'                 ; check if adding
      jz    i1
      cpi   '-'                 ; check if subtracting
      jz    i1
      cpi   30h                 ; these 4 lines check if user has entered a number
      cc    err
      jc    ir0
      cpi   3Ah
      cnc   err  
      jnc   ir0
      call  x10                 ; multiply HL by 10
      sui   '0'                 ; convert ascii input to numeric
      lxi   b,0
      mov   c,a
      dad   b                   ; add A to HL
      mvi   c,conin
      jmp   ir0                 ; loop back
i1:   push  psw
      mov   d,h
      mov   e,l
      lxi   h,0
ir1:  call  bdos
      cpi   '='                 ; check for end of input
      jz    idn
      cpi   30h                 ; these 4 lines check if user has entered a number
      cc    err
      jc    ir1
      cpi   3Ah
      cnc   err
      jnc   ir1
      call  x10                 ; multiply HL by 10
      sui   '0'                 ; convert ascii input to numeric
      lxi   b,0
      mov   c,a
      dad   b                   ; add A to HL
      mvi   c,conin
      jmp   ir1
idn:  pop   psw
i2:   pop   b                   ; pop destroyed registers
      ret
      
; error handling subroutine
; hides errors in input
; input: null
; output: null
; destroys BC and HL pairs
; stack size 4

err:  push  b
      push  d
      mvi   c,conout            ; set CP/M for character output
      mvi   e,8h                ; move BACKSPACE char to E register 
      call  bdos                ; execute BACKSPACE
      mvi   e,' '               ; print SPACE over error character 
      call  bdos                
      mvi   e,8h                ; execute another BACKSPACE
      call  bdos
      mvi   c,conin             ; set CP/M back to character input
      pop   d
      pop   b
      ret                       ; pop from stack and return


; x10 subroutine
; multiplies HL register by 10
; input: HL register pair
; output: HL register pair
; destroys 
; stack size 2

x10:  push  psw		              ; store value of destroyed registers in stack
      push  b
      mov   a,l
      add   a
      mov   c,a
      mov   a,h
      adc   a
      mov   b,a                 ; BC holds double of original HL value 

      mov   a,l
      add   a
      mov   l,a
      mov   a,h
      adc   a                  
      mov   h,a                 ; HL is 2X

      mov   a,l
      add   a
      mov   l,a
      mov   a,h
      adc   a                  
      mov   h,a                 ; HL is 4X

      mov   a,l
      add   a
      mov   l,a
      mov   a,h
      adc   a                  
      mov   h,a                 ; HL is 8x

      mov   a,l
      add   c
      mov   l,a
      mov   a,h
      adc   b
      mov   h,a                 ; BC (2X) is added to HL (8X) for total of 10X

			pop   b			            	; return BC to original value
      pop   psw                 ; return HL to original value
			ret		  			            ; return to main function

; d10 subroutine
; divides number in BC pair by 10
; input: BC pair
; output: quotient in BC pair

d10:  push  h
      push  psw
      xchg
      ;mov   h,b
      ;mov   l,c
      mvi   c,10
      lxi   d,0
dr0:  mov   a,l
      sub   c
      mov   l,a
      jnc   dr1
      dcr   h
dr1:  inx   h
      mov   a,h
      cpi   0
      jnz   dr0
      mov   a,l
      cmp   c
      jnc   dr0
      xchg 
      ;mov   b,h
      ;mov   c,l
      pop   psw
      pop   h
      ret

; print subroutine
; prints value of number in HL pair
; input: HL pair
; output: prints to screen
; destroys
; stack size
prnt: push  b
      push  d
      push  h
      jnc   pst
      mvi   e,'-'
      call  bdos
      mov   a,l
      cma
      mov   l,a
      mov   a,h
      cma
      mov   h,a
      inx   h
pst:  lxi   b,10000
pr0:  mvi   e,'0'
pr1:  mov   a,l
      sub   c
      mov   l,a
      mov   a,h
      sbb   b
      mov   h,a                 ; subtract BC from HL
      jc    pr2
      inr   e
      jmp   pr1
pr2:  dad   b
      push  b
      mvi   c,conout
      call  bdos
      pop   b
      ; 0010011100010000
      ; 0000001111101000
      ;         01100100
      ;         00001010
      ;         00000001
      d10
      jmp   pr0

pd0:  pop   h
      pop   d
      pop   b
      ret

m0:   db    'Simple Calculator',lf,lf,cr,'Type an addition or'
      db    ' subtraction problem, or enter to end$'
m1:   db    'Thank you for using the Simple Calculator$'
      ds    40                  ; give space for stack
			sp0 	equ $		            ; stack address
			end					              ; ends assembler
