// Practica 4 de SEM
// Por Manuel Martinez-Almeida

`include "memoria.v"

module controlador(addrD, addrA, addrB, MBSelect, FS, MDSelect, RW, MW, constin, busA, N, Z, clk);
    input N, Z, clk;
    input [15:0] busA;

    output [15:0] constin;
    output [2:0] addrD, addrA, addrB;
    output [3:0] FS;
    output MBSelect, MDSelect, RW, MW;

    wire [15:0] counter, instruccion;
    wire [5:0] AD;
    wire [2:0] BC;

    controlPC PC(counter, busA, N, Z, PL, JB, BC, AD, clk);
    memoraROM ROM(instruccion, counter);
    decodificador DEC(addrD, addrA, addrB, MBSelect, FS, MDSelect, RW, MW, PL, JB, BC, AD, constin, instruccion);

endmodule


module controlPC(PC, busA, N, Z, PL, JB, BC, AD, clk);
    input [15:0] busA;
    input [5:0] AD;
    input [2:0] BC;
    input N, Z, PL, JB, clk;

    output [15:0] PC;

    reg [15:0] PC;
    reg Nstored, Zstored;

    initial begin
        PC = 0;
    end
    always @ (posedge clk) begin
        #10 casex ({PL,JB,BC,Nstored,Zstored})
            7'b11zzzzz:
                PC = busA;

            7'b100011z, // si N
    		7'b10011z1, // si Z
    		7'b101010z, // si NOT N
    		7'b10111z0: // si NOT Z
                PC = PC + {{10{AD[5]}},AD};
            default:
                PC = PC + 1;
        endcase
        Nstored = N;
        Zstored = Z;
    end
endmodule


module decodificador(addrD, addrA, addrB, MBSelect, FS, MDSelect, RW, MW, PL, JB, BC, AD, constin, instruccion);
    input [15:0] instruccion;

    output [15:0] constin;
    output [2:0] addrD, addrA, addrB, BC;
    output [5:0] AD;
    output [3:0] FS;
    output MBSelect, MDSelect, RW, MW, PL, JB;

    assign addrB = instruccion[2:0];
    assign addrA = instruccion[5:3];
    assign addrD = instruccion[8:6];
    assign MBSelect = instruccion[15];
    assign MDSelect = instruccion[13];

    // escritura en registro
    not(RW, instruccion[14]);

    // escritura en memoria RAM
    not(not15, instruccion[15]);
    and(MW, instruccion[14], not15);

    // operacion de la unidad funcional
    not(notPL, PL);
    and(FS[3], instruccion[12], notPL);
    and(FS[2], instruccion[11], notPL);
    and(FS[1], instruccion[10], notPL);
    and(FS[0], instruccion[9], notPL);

    // carga de PC
    and(PL, instruccion[15], instruccion[14]);
    
    assign JB = instruccion[13];
    assign BC = instruccion[11:9];
    assign AD = {addrD,addrB};
    assign constin = addrB;

endmodule
