
;%%%%%%%%%%%%%%%% S Q R T %%%%%%%%%%%%%%%%%
;%%%%%%%% Manuel Martinez-Almeida %%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

main:

; cargar RO <- M[M[0]]
LDI R0 0
LD R0 R0
LD R0 R0

; inicializamos mascara en R7 = 00000001
LDI R7 1

; inicializamos el contador de potencias
LDI R1 1

loop:
    ; incrementamos el contador del resultado final
    INC R1 R1

    ; R2 va a ser el resultado de la multiplicacion
    LDI R2 0
    ; R3 y R4 los usamos como registros auxiliares durante la multiplicacion
    MOVA R3 R1
    MOVA R4 R1

mult:
    ; calculamos si el primer bit es igual a 0 y guardamos en R6
    AND R6 R3 R7

    ; guardamos R4 en R5 en caso de tener que hacer la suma parcial
    MOVA R5 R4

    ; R4*2 y R3/2
    SHL R4 R4
    SHR R3 R3

    ; si el primer bit es 0, vamos al siguiente digito sin hacer la suma parcial
    MOVA R6 R6
    BRZ mult

    ; si el primer bit es 1, sumamos R5 al registro acumulador R2
    ADD R2 R2 R5

    ; si mascara es 0, terminamos multiplicacion
    MOVA R3 R3
    BRZN mult


; calculamos la resta entre el resultado de la multiplicacion y el valor buscado
; si la resta es negativa, significa que todavia no hemos llegado al resultado
SUB R2 R2 R0
BRN loop

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
