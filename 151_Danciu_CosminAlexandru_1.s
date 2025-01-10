.data
    Citire: .asciz "%d"
    AfisGet: .asciz "((%d, %d), (%d, %d))\n"
    Afis: .asciz "%d: ((%d, %d), (%d, %d))\n"
    v: .space 4194304
    nr_op: .space 4
    op: .space 4
    dimensiune: .space 4
    nr_fisiere: .space 4
    descriptor: .space 4
    x: .space 4
    y: .space 4
    copieY: .long 0
    copieY2: .long 0
    copieY3: .long 0
    rand: .long 0
    coloana: .long 0
    copieRand: .long 0
    copieColoana: .long 0
.text 

Add:
    etZero:
        movl $0, %ebx
        cmp coloana, %ecx
        je etSchimbaRand
        movl v(, %ecx, 4), %edx
        cmp $0, %edx
        je etSearch
        incl %ecx
        jmp etZero

    etSearch:
        cmp coloana, %ecx
        je etSchimbaRand
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

    etSchimbaRand:
        movl coloana, %ecx
        movl rand, %edx
        cmp $1023, %edx
        je etLeaveAdd
        addl $1024, coloana
        incl rand
        jmp etZero

    etLeaveAdd:
        movl y, %eax
        subl x, %eax
        incl %eax
        cmp dimensiune, %eax
        jne etLeaveAdd2
        movl rand, %eax
        movl $0, %ebx
        incl %eax
        movl y, %ecx
        movl %ecx, copieY3
        jmp etRanduri

    etLeaveAdd2:
        movl $0, rand
        movl $0, x
        movl $0, y
        ret

    etRanduri:
        cmp $0, %eax
        je etLeaveAdd3
        decl %eax
        addl $1024, %ebx

    etLeaveAdd3:
        movl y, %eax
        divl %ebx
        movl %edx, y
        incl %edx
        subl dimensiune, %edx
        movl %edx, x
        ret

Get:
    movl $0, %ecx 
    movl $0, rand
    movl $1024, coloana
    etPreia:
        cmp coloana, %ecx
        je etSchimbaRandGet
        movl v(, %ecx, 4), %edx
        cmp descriptor, %edx
        je etGasit
        incl %ecx
        jmp etPreia

    etSchimbaRandGet:   
        movl coloana, %ecx
        movl rand, %edx
        cmp $1023, %edx
        je etNegasit
        addl $1024, coloana
        incl rand
        jmp etPreia

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
    
    etNegasit:
        movl $0, rand
        movl $0, coloana
        movl $0, x
        movl $0, y
        ret

    etLeaveGet:
        movl $1024, %ebx
        movl y, %eax
        incl %eax
        subl x, %eax
        movl %eax, dimensiune
        movl y, %eax
        divl %ebx
        movl %edx, y
        incl %edx
        subl dimensiune, %edx
        movl %edx, x
        ret

Delete:
    movl $0, %ecx
    etGaseste:
        cmp $4194304, %ecx
        je etLeaveDelete
        movl v(, %ecx, 4), %edx
        cmp descriptor, %edx
        je etSterge
        incl %ecx
        jmp etGaseste
    
    etSterge:
        cmp descriptor, %edx
        jne etLeaveDelete
        movl $0, v(, %ecx, 4)
        incl %ecx
        movl v(, %ecx, 4), %edx
        jmp etSterge
    
    etLeaveDelete:
        ret

Intervale:
    movl $0, %ecx 
    movl $0, rand
    movl $1024, coloana
    movl $0, descriptor
    etGasesteDescriptor:
        cmp coloana, %ecx
        je etSchimbaRandIntervale
        movl v(, %ecx, 4), %edx
        cmp descriptor, %edx
        jne etCautaDreapta
        incl %ecx
        jmp etGasesteDescriptor
    
    etSchimbaRandIntervale:
        movl coloana, %ecx
        movl rand, %edx
        cmp $1023, %edx
        je etLeaveIntervale
        addl $1024, coloana
        incl rand
        jmp etGasesteDescriptor

    etCautaDreapta:
        movl %edx, descriptor
        movl %ecx, x
        jmp etCautaY

    etCautaY:
        incl %ecx
        movl v(, %ecx, 4), %edx
        cmp descriptor, %edx
        jne etY
        jmp etCautaY

    etY:
        movl %ecx, y
        decl y

    etAfiseaza:
        movl $1024, %ebx
        movl y, %eax
        movl %eax, copieY
        incl %eax
        subl x, %eax
        movl %eax, dimensiune
        movl y, %eax
        divl %ebx
        movl %edx, y
        incl %edx
        subl dimensiune, %edx
        movl %edx, x

        pushl y
        pushl rand
        pushl x
        pushl rand
        pushl descriptor
        pushl $Afis
        call printf
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx

        movl copieY, %ecx
        incl %ecx
        movl $0, descriptor
        jmp etGasesteDescriptor

    etLeaveIntervale:
        ret

Defragmentation:
    movl $0, copieY2
    movl $0, %ecx
    movl $0, descriptor
    movl $1024, coloana
    movl $0, rand
    etFindDescriptor:
        cmp coloana, %ecx
        je etSchimbaRandDefragmentation
        movl v(, %ecx, 4), %edx
        cmp descriptor, %edx
        jne etFindDreapta
        incl %ecx
        jmp etFindDescriptor
    
    etSchimbaRandDefragmentation:
        movl coloana, %ecx
        movl rand, %edx
        cmp $1023, %edx
        je etLeaveDefragmentation
        addl $1024, coloana
        incl rand
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
        movl copieY2, %ecx
        cmp $0, %ecx
        je etSeteaza1
        movl copieRand, %eax
        movl rand, %ecx
        movl %ecx, copieRand
        movl %eax, rand
        movl copieColoana, %eax
        movl coloana, %ecx
        movl %ecx, copieColoana
        movl %eax, coloana
        movl copieY2, %eax
        movl y, %ecx
        movl %ecx, copieY2
        movl %eax, %ecx
        call Add
        jmp etDefragAfiseaza
    
    etSeteaza1:
        movl rand, %ecx
        movl %ecx, copieRand
        movl coloana, %ecx
        movl %ecx, copieColoana
        movl y, %ecx
        movl %ecx, copieY2
        movl $0, %ecx
        movl $1024, coloana
        movl $0, rand
        call Add
        jmp etDefragAfiseaza

    etDefragAfiseaza:
        movl copieRand, %ecx
        movl rand, %eax
        movl %eax, copieRand
        movl %ecx, rand
        movl copieColoana, %ecx
        movl coloana, %eax
        movl %eax, copieColoana
        movl %ecx, coloana
        movl copieY2, %ecx
        movl copieY3, %eax
        movl %eax, copieY2
        incl %ecx
        movl $0, descriptor
        jmp etFindDescriptor

    etLeaveDefragmentation:
        ret

.global main 
main:
    pushl $nr_op
    pushl $Citire
    call scanf
    pushl %ebx
    pushl %ebx

    etloop:
        movl nr_op, %ecx
        cmp $0, %ecx
        je etexit

        pushl $op
        pushl $Citire
        call scanf
        pushl %ebx
        pushl %ebx

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
        movl $0, rand
        movl $1024, coloana

        call Add

        pushl y
        pushl rand
        pushl x
        pushl rand
        pushl descriptor
        pushl $Afis
        call printf
        popl %ebx
        popl %ebx
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
        pushl rand
        pushl x
        pushl rand
        pushl $AfisGet
        call printf
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx

        jmp etloop

    etDelete:
        movl $0, descriptor
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
        call Intervale
        jmp etloop

    etexit:
        pushl $0
        call fflush
        popl %ebx
        movl $1, %eax
        movl $0, %ebx
        int $0x80
