
;%%%%%%%%%%%%%%%% S Q R T %%%%%%%%%%%%%%%%%
;%%%%%%%% Manuel Martinez-Almeida %%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

main:

; cargar RO <- M[0]
LDI R0 0
LD R0 R0

; inicializamos los contadores
LDI R1 1
LDI R2 1

loop:
    ; R2 = (X-1)^2
    ; R3 = 2(X-1)
    ; R2 = X^2 = 2(X-1) + (X-1)^2 + 1
    SHL R3 R1
    ADD1 R2 R3 R2
    ; R1++
    INC R1 R1

    ; if(X^2 < R0) continue; else break;
    SUB R3 R2 R0
    BRN loop


MOVA R0 R1
MOVA R2 R1
MOVA R3 R1
MOVA R4 R1
MOVA R5 R1
MOVA R6 R1
MOVA R7 R1

HALT
