// Practica 4 de SEM
// Por Manuel Martinez-Almeida

`timescale 1ns / 10ps

`include "registros.v"
`include "unidad_funcional.v"

module ruta_de_datos(
        V, Z, N, C, busA, busB,
        FS, addrD, addrA, addrB,
        MBSelect, MDSelect,
        RW, constin, datain,
        clk);

    input MBSelect, MDSelect, RW, clk;
    input [2:0] addrD, addrA, addrB;
    input [3:0] FS;
    input [15:0] constin, datain;

    output V, Z, N, C;
    output [15:0] busA, busB;

    wire [15:0] busD, B, F;

    registros REG(busA, B, addrA, addrB, addrD, RW, busD, clk);
    mux MUX_B(busB, B, constin, MBSelect);

    unidad_funcional UNIDAD(F, V, Z, N, C, FS, busA, busB);
    mux MUX_D(busD, F, datain, MDSelect);

endmodule
