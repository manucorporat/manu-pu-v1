// Practica 4 de SEM
// Por Manuel Martinez-Almeida

`timescale 1ns / 10ps
`include "mux.v"

module unidad_funcional(F, V, Z, N, C, FS, A, B);
    input [3:0] FS;
    input [15:0] A, B;

    output [15:0] F;
    output V, Z, N, C;

    wire [15:0] salida_alu;
    wire [15:0] salida_shift;

    alu ALU1 (salida_alu, V, Z, N, C, A, B, FS);
    desplazador SHIFTER1 (salida_shift, B, FS[1:0]);
    mux MUX_ALU (F, salida_alu, salida_shift, FS[3:2] == 2'b11);

endmodule


module desplazador(G, B, select);
    input [15:0] B;
    input [1:0] select;

    output [15:0] G;

    assign #5 G =
        (select == 2'b00) ? B :
        (select == 2'b01) ? B >> 1 :
        (select == 2'b10) ? B << 1 :
        0;
endmodule


module alu(G, V, Z, N, C, A, B, select);
    input [15:0] A, B;
    input [3:0] select;

    output [15:0] G;
    output V, Z, N, C;

    assign #20 {C, G} =
        (select == 4'b0000) ? A :
        (select == 4'b0001) ? A + 1 :
        (select == 4'b0010) ? A + B :
        (select == 4'b0011) ? A + B + 1 :
        (select == 4'b0100) ? {1'b0,A} + {1'b0,~B} :
        (select == 4'b0101) ? {1'b0,A} + {1'b0,~B} + 1 :
        (select == 4'b0110) ? A - 1 :
        (select == 4'b0111) ? A :

        (select[1:0] == 2'b00) ? {1'b0,A & B} :
        (select[1:0] == 2'b01) ? {1'b0,A | B} :
        (select[1:0] == 2'b10) ? {1'b0,A ^ B} :
        {1'b0,~A};

    // comprobar desbordamiento
    assign V =
        (select == 4'b0000) ? 0 :
        (select == 4'b0001) ? A[15]==0 && G[15]!=0 :
        (select == 4'b0110) ? A[15]==0 && G[15]!=0 :
        (select == 4'b0111) ? 0 :
        (select[3] == 1) ? 0 :
        (A[15] == B[15]) && (G[15] != A[15]);

    // salida es negativa, comprobamos el ultimo bit
    assign N = (G[15] == 1);

    // salida es 0
    assign #2 Z = (G == 0);

endmodule
