// Practica 4 de SEM
// Por Manuel Martinez-Almeida

`include "controlador.v"
`include "ruta_de_datos.v"

module cpu(clk);
    input clk;

    wire [15:0] busA, busB, constin, datain;
    wire [2:0] addrD, addrA, addrB;
    wire [3:0] FS;

    controlador CNTR (
        addrD, addrA, addrB, MBSelect, FS, MDSelect, RW, MW, constin,
        busA, N, Z, clk);

    memoriaRAM RAM (datain, busB, busA, MW, clk);

    ruta_de_datos RUT_DATOS (
        V, Z, N, C, busA, busB,

        FS, addrD, addrA, addrB,
        MBSelect, MDSelect,

        RW, constin, datain,
        clk);

endmodule
