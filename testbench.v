// Practica 4 de SEM
// Por Manuel Martinez-Almeida

`timescale 1ns / 10ps

`include "cpu.v"

module testbench;
    reg clk;
    reg [15:0] ciclo;

    initial begin
        ciclo = 0;
        clk = 0;
    end

    always begin
        #100 clk = 0;
        #100 clk = 1;
        ciclo = ciclo + 1;
    end

    cpu CORE1 (clk);

    initial begin
        $dumpfile("out.vcd");
        $dumpvars(0, CORE1, ciclo);
        #10000 $finish;
    end

endmodule
