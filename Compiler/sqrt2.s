
;%%%%%%%%%%%%%%%% S Q R T %%%%%%%%%%%%%%%%%
;%%%%%%%% Manuel Martinez-Almeida %%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

main:

; cargar RO <- M[M[0]]
LDI R0 0
LD R0 R0
LD R0 R0

; inicializamos el contador de potencias
LDI R1 1

; R2 almacena los cuadrados
LDI R2 1

loop:
    ; R2 = (X-1)^2
    ; R3 = 2(X-1)
    ; R2 = X^2 = 2(X-1) + (X-1)^2 + 1
    SHL R3 R1
    ADD1 R2 R3 R2
    INC R1 R1

    SUB R3 R2 R0
    BRN loop


MOVA R0 R1
MOVA R2 R1
MOVA R3 R1
MOVA R4 R1
MOVA R5 R1
MOVA R6 R1
MOVA R7 R1

; RESULTADO ENCONTRADO! almacenado en R2
; leer referencia de trabajo
LDI R0 0
LD R2 R0

; obtener direccion donde guardamos el resultado y guardar
DEC R2 R2
ST R2 R1

; decrementar para siguiente referencia de trabajo
DEC R2 R2
ST R0 R2

; si la referencia es 0, terminamos
MOVA R2 R2
BRZN main

; FIN DE EJECUCION
HALT
