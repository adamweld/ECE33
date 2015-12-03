; Adam Weld
; Program 4
; Simple Calculator
; Includes extra credit enchancements
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
      call  bdos                ; print line feed
      mvi   e,cr
      call  bdos                ; print character return
      mvi   e,'>' 
      call  bdos    
      call  bdos                ; print both >>
      call  inpt                ; take user input
      push  psw
      mov   a,h
      cpi   128                 ; check HL pair for overflow
      jnc    ovr                 ; if we have overflow
      mov   a,d
      cpi   128                 ; check DE pair for overflow
      jnc    ovr                 ; if we have overflow
      pop   psw                 ; restore PSW to previous state
      cpi   '+'                 ; check if numbers should be added 
      jz    add   
      cpi   cr                  ; check user wants to exit
      jz    d0
sub:  mov   a,e                 ; next 4 lines subtract DE from HL
      sub   l                   ; subtract L from E
      mov   l,a                 ; move result back to L
      mov   a,d     
      sbb   h                   ; subtract D from H            
      mov   h,a                 ; move result back to H
      jnc   pst                 ; if result is positive, jump to print loop
      mvi   e,'-'
      call  bdos                ; otherwise prepend with '-'
      mov   a,l                 ; these lines complement the number
      cma                       ; complement lower byte
      mov   l,a
      mov   a,h
      cma                       ; complement higher byte
      mov   h,a   
      inx   h                   ; add 1 to result
      jmp   pst 
add:  dad   d                   ; add contents of DE to HL
pst:  mov   a,h
      cpi   128                 ; check HL result for overflow
      jnc    ovr                 ; if we have overflow
      mvi   d,'0'
      lxi   b,10000             ; start with value of 10000 
      call  prnt                ; print digit if it's a 0
      lxi   b,1000              ; now 1000
      call  prnt
      lxi   b,100               ; now 100
      call  prnt
      lxi   b,10                ; now 10s place
      call  prnt
      lxi   b,1                 ; 1s place
      call  prnt
      jmp   r0                  ; take another input
ovr:  mvi   c,sprint            ; print overflow message, CMA -> sprint
      lxi   d,m2                ; load DE with overflow message
      call  bdos                ; print message
      mvi   c,conout
      jmp   r0                  ; take next input
d0:   mvi   c,sprint
      lxi   d,m1                ; print exit message
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
      cc    err                 ; call err subroutine to delete invalid characters
      jc    ir0                 ; loop back if error deleted
      cpi   3Ah                 ; same here, checking higher bounds
      cnc   err  
      jnc   ir0                 ; loop back if we have an error entry
      call  x10                 ; multiply HL by 10 (old sum value)
      sui   '0'                 ; convert ascii input to numeric
      lxi   b,0                 ; clear BC pair
      mov   c,a                 ; move input value to C
      dad   b                   ; add BC to HL
      mvi   c,conin             ; C now takes input again
      jmp   ir0                 ; loop back
i1:   push  psw                 ; push PSW so we will know if adding/subtracting
      mov   d,h                 ; move HL to DE so we can fill HL again
      mov   e,l
      lxi   h,0                 ; clear HL for next number
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
; stack size 6

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
; destroys PSW, BC
; stack size 4

x10:  push  psw		              ; store value of destroyed registers in stack
      push  b
      dad   h                   ; doubles HL pair
      mov   b,h
      mov   c,l                 ; copies value in HL to BC
      dad   h                   ; HL is 4x
      dad   h                   ; HL is 8x
      dad   b                   ; HL is 8x + 2x = 10x
			pop   b			            	; return BC to original value
      pop   psw                 ; return HL to original value
			ret		  			            ; return to main function


; print subroutine
; prints value of number in HL pair, at power of BC pair
; input: HL pair, BC pair
; output: prints to screen one digit, removes digit that is printed from HL number
; destroys PSW
; stack size 4
prnt: push  psw                 ; store destroyed registers 
pr0:  mvi   e,'0'               ; set e to ASCII zero
pr1:  mov   a,l                 ; next 4 lines subtract BC from HL
      sub   c
      mov   l,a
      mov   a,h
      sbb   b                   ; use borrow on higher byte
      mov   h,a                 
      jc    pr2                 ; if carry, move to next section
      inr   e                   ; if not increase E
      mvi   d,0                 ; D starts as 30H
      ;if we zero it we know to start printing 0 characters
      jmp   pr1                 ; loop back
pr2:  dad   b                   ; add BC back onto HL
      mov   a,d                 ; this part makes sure not to print leading zeroes
      cmp   e                   ; compare char in E with D (by default will return positive)
      jnc   pd0                 ; if so we skip printing the character if it's a 0
      mvi   c,conout            ; if not we print it
      mvi   d,1                 ; 
      call  bdos
pd0:  pop   psw                 ; pop registers and return
      ret

m0:   db    'Simple Calculator (Enchanced)',lf,lf,cr,'Type an addition or'
      db    ' subtraction problem, or enter to end$'
m1:   db    'Thank you for using the Simple Calculator$'
m2:   db    '    **** overflow$'
      ds    40                  ; give space for stack
			sp0 	equ $		            ; stack address
			end					              ; ends assembler
