; Adam Weld
; Program 3
;
   bdos     equ    5           ; CP/M function call address
   boot     equ    0           ; address to get back to CP/M
   conin    equ    1           ; keyboard read function number
   conout   equ    2           ; console output function number
   sprint   equ    9           ; string print function number
   cr       equ    0Dh         ; value of ASCII code of <CR>
   lf       equ    0Ah         ; value of ASCII code of line feed
;
      org   100h
      lxi   sp,sp0
      mvi   b,10
      lxi   h,n0
      mvi   a,0
clr:  mov   m,a
      inx   h
      dcr   b
      jnz   clr
      lxi   d,m0
      mvi   c,sprint
      call  bdos
      call  inpt
      lxi   d,m1
      call  bdos
      call  hist
      lxi   d,m2
      call  bdos
      jmp   boot

; input subroutine
; takes your goddamn inputs
inpt: push  psw
      push  b
      push  d
      push  h
      lxi   d,0
      mvi   c,conin
ir0:  call  bdos
      cpi   cr
      jz    idn
      cpi   30h
      jc    ierr
      cpi   3Ah
      jnc   ierr   
      sui   '0'
      mov   e,a
      lxi   h,n0
      dad   d
      mov   a,m
      inr   a
      mov   m,a
      jmp   ir0
ierr: mvi   c,conout
      mvi   e,8h
      call  bdos
      mvi   e,' '
      call  bdos
      mvi   e,8h
      call  bdos
      mvi   c,conin
      jmp   ir0
idn:  pop   h
      pop   d
      pop   b
      pop   psw
      ret
      

; histogram subrouting
; prints a goddamn histogram
hist: push  psw
      push  b
      push  h
      mvi   b,'0'
      mvi   c,conout
      lxi   h,n0
hr0:  mvi   e,lf
      call  bdos
      mvi   e,cr
      call  bdos
      mov   e,b
      call  bdos
      mvi   e,':'
      call  bdos
      mvi   e,' '
      call  bdos
      mvi   e,'|'
      mov   a,m
      cpi   0
      jz    hr2
hr1:  call  bdos
      dcr   a
      jnz   hr1
hr2:  inx   h
      inr   b
      mov   a,b
      cpi   3Ah
      jnz   hr0
hdn:  pop 	h
      pop   b
			pop 	psw			; pop destroyed registers
			ret					  ; return



m0:   db    'The Number Analser Mk.13'
      db    cr,lf,'enter some goddamn numbers shit'
      db    cr,lf,'gimme those digits: $'
m1:   db    cr,lf,'numbers got straight analzed:',lf,cr,'$'
m2:   db    cr,lf,'thank you for playing!$'
n0:   ds    10      ; save space for 10 values
      db    '$'
      ds    20
			sp0 	equ $		; stack address
			end					  ; ends assembler
