.data
    Citire: .asciz "%d"
    AfisGet: .asciz "(%d, %d)\n"
    Afis: .asciz "%d: (%d, %d)\n"
    v: .space 4096
    nr_op: .space 4
    op: .space 4
    dimensiune: .space 4
    nr_fisiere: .space 4
    descriptor: .space 4
    nr_descriptori: .long 0
    cnt: .long 0
    pozitie: .long 0
    x: .space 4
    y: .space 4
.text 

Add:
    movl dimensiune, %eax
    movl $8, %ebx
    movl $0, %edx
    divl %ebx
    cmp $0, %edx
    jne etPlus
    jmp etNotPlus

    etPlus:
        incl %eax
        movl %eax, dimensiune
    etNotPlus:
        movl %eax, dimensiune

    movl $0, %ecx 

    etZero:
        movl $0, %ebx
        cmp $1024, %ecx
        je etLeaveAdd
        movl v(, %ecx, 4), %edx
        cmp $0, %edx
        je etSearch
        incl %ecx
        jmp etZero

    etSearch:
        cmp $1024, %ecx
        je etLeaveAdd
        movl v(, %ecx, 4), %edx
        cmp $0, %edx
        jne etZero
        incl %ebx
        cmp dimensiune, %ebx
        je etDistanta
        incl %ecx
        jmp etSearch

    etDistanta:
        subl dimensiune, %ecx
        movl %ecx, x
        incl x
        movl x, %eax
        addl dimensiune, %eax
        movl %eax, y
        decl y
        movl x, %ecx
        movl descriptor, %eax
        jmp etDepune

    etDepune:
        movl %eax, v(, %ecx, 4)
        cmp y, %ecx
        je etLeaveAdd
        incl %ecx
        jmp etDepune
    etLeaveAdd:
        movl y, %eax
        subl x, %eax
        incl %eax
        cmp dimensiune, %eax
        jne etLeaveAdd2
        incl nr_descriptori
        ret

    etLeaveAdd2:
        movl $0, x
        movl $0, y
        ret

Get:
    movl $0, %ecx
    etPreia:
        cmp $1024, %ecx
        je etNegasit
        movl v(, %ecx, 4), %edx
        cmp descriptor, %edx
        je etGasit
        incl %ecx
        jmp etPreia

    etNegasit:
        movl $0, x
        movl $0, y
        jmp etLeaveGet
    
    etGasit:
        movl %ecx, x
        incl %ecx
        jmp etFindY

    etFindY:   
        movl v(, %ecx, 4), %edx
        cmp descriptor, %edx
        jne etLeaveGet
        movl %ecx, y
        incl %ecx
        jmp etFindY
    
    etLeaveGet:
        ret

Delete:
    movl $0, %ecx
    etGaseste:
        cmp $1024, %ecx
        je etLeaveDelete
        movl v(, %ecx, 4), %edx
        cmp descriptor, %edx
        je etSterge1
        incl %ecx
        jmp etGaseste
    
    etSterge1:
        decl nr_descriptori
        jmp etSterge2

    etSterge2:
        cmp descriptor, %edx
        jne etLeaveDelete
        movl $0, v(, %ecx, 4)
        incl %ecx
        movl v(, %ecx, 4), %edx
        jmp etSterge2
    
    etLeaveDelete:
        ret

Intervale:
    movl $0, %ecx
    movl $0, cnt
    movl $0, descriptor
    etGasesteDescriptor:
        cmp $1024, %ecx
        je etLeaveIntervale
        movl nr_descriptori, %eax
        cmp cnt, %eax
        je etLeaveIntervale
        movl v(, %ecx, 4), %edx
        cmp descriptor, %edx
        jne etCautaDreapta
        incl %ecx
        jmp etGasesteDescriptor
    
    etCautaDreapta:
        movl %edx, descriptor
        movl %ecx, x
        incl cnt  
        jmp etCautaY

    etCautaY:
        cmp $1024, %ecx
        je etY
        incl %ecx
        movl v(, %ecx, 4), %edx
        cmp descriptor, %edx
        jne etY
        jmp etCautaY

    etY:
        movl %ecx, y
        decl y
        jmp etAfiseaza
    
    etAfiseaza:
        pushl y
        pushl x
        pushl descriptor
        pushl $Afis
        call printf
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx

        movl y, %ecx
        incl %ecx
        movl $0, descriptor
        jmp etGasesteDescriptor

    etLeaveIntervale:
        ret

Defragmentation:
    movl $0, %ecx
    movl $0, cnt
    movl $0, pozitie
    movl $0, descriptor
    etFindDescriptor:
        movl nr_descriptori, %eax
        cmp cnt, %eax
        je etLeaveDefragmentation
        movl v(, %ecx, 4), %edx
        cmp descriptor, %edx
        jne etFindDreapta
        incl %ecx
        jmp etFindDescriptor
    
    etFindDreapta:
        movl %edx, descriptor
        movl %ecx, x 
        jmp etDefragGasesteY

    etDefragGasesteY:
        incl %ecx
        movl v(, %ecx, 4), %edx
        cmp descriptor, %edx
        jne etDefragY
        jmp etDefragGasesteY

    etDefragY:
        decl %ecx
        movl %ecx, y
        subl x, %ecx
        incl %ecx
        movl %ecx, dimensiune
        movl x, %ecx
        jmp etPuneZero

    etPuneZero:
        cmp y, %ecx
        je etSeteaza
        movl $0, v(, %ecx, 4)
        incl %ecx
        jmp etPuneZero
    
    etSeteaza:
        movl $0, v(, %ecx, 4)
        movl pozitie, %ecx
        incl cnt
        movl %ecx, x
        addl dimensiune, %ecx
        movl %ecx, y
        movl x, %ecx
        movl descriptor, %eax
        jmp etRepune
    
    etRepune:
        cmp y, %ecx
        je etDefragAfiseaza
        movl %eax, v(, %ecx, 4)
        incl %ecx
        jmp etRepune
    
    etDefragAfiseaza:
        decl y
        pushl y
        pushl x
        pushl descriptor
        pushl $Afis
        call printf
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx

        movl y, %ecx
        incl %ecx
        movl %ecx, pozitie
        movl $0, descriptor
        jmp etFindDescriptor

    etLeaveDefragmentation:
        ret

.global main 
main:
    pushl $nr_op
    pushl $Citire
    call scanf
    popl %ebx
    popl %ebx

    etloop:
        movl nr_op, %ecx
        cmp $0, %ecx
        je etexit

        pushl $op
        pushl $Citire
        call scanf
        popl %ebx
        popl %ebx

        decl nr_op

        movl op, %ecx
        cmp $1, %ecx
        je etAdd
        cmp $2, %ecx
        je etGet
        cmp $3, %ecx
        je etDelete
        cmp $4, %ecx
        je etDefragmentation
    

    etAdd:
        pushl $nr_fisiere
        pushl $Citire
        call scanf
        popl %ebx
        popl %ebx

        jmp etFisiere

    etFisiere:
        movl nr_fisiere, %ecx
        cmp $0, %ecx
        je etloop

        pushl $descriptor
        pushl $Citire
        call scanf
        popl %ebx
        popl %ebx

        pushl $dimensiune
        pushl $Citire
        call scanf
        popl %ebx
        popl %ebx

        decl nr_fisiere
        
        call Add

        pushl y
        pushl x
        pushl descriptor
        pushl $Afis
        call printf
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx

        jmp etFisiere

    etGet:
        pushl $descriptor
        pushl $Citire
        call scanf
        popl %ebx
        popl %ebx

        call Get

        pushl y
        pushl x
        pushl $AfisGet
        call printf
        popl %ebx
        popl %ebx
        popl %ebx

        jmp etloop

    etDelete:
        pushl $descriptor
        pushl $Citire
        call scanf
        popl %ebx
        popl %ebx

        call Delete
        call Intervale

        jmp etloop

    etDefragmentation:
        call Defragmentation
        jmp etloop

    etexit:
        pushl $0
        call fflush
        popl %ebx
        movl $1, %eax
        movl $0, %ebx
        int $0x80
