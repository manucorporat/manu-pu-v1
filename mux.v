// Practica 4 de SEM
// Por Manuel Martinez-Almeida

`timescale 1ns / 10ps

module mux(F, A, B, select);
    output [15:0] F;
    input [15:0] A, B;
    input select;

    assign #2 F = (select == 0)
     ? A
     : B;
endmodule
