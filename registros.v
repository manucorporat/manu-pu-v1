// Practica 4 de SEM
// Por Manuel Martinez-Almeida

`timescale 1ns / 10ps

module registros(A, B, addrA, addrB, addrD, write, D, clk);
    input [2:0] addrA, addrB, addrD;
    input [15:0] D;
    input write, clk;

    output [15:0] A, B;

    reg [15:0] R0, R1, R2, R3, R4, R5, R6, R7;

    initial begin
        R0 = 0;
        R1 = 0;
        R2 = 0;
        R3 = 0;
        R4 = 0;
        R5 = 0;
        R6 = 0;
        R7 = 0;
    end

    always @ (posedge clk) begin
        case ({write, addrD})
            4'b1000: #3 R0 = D;
            4'b1001: #3 R1 = D;
            4'b1010: #3 R2 = D;
            4'b1011: #3 R3 = D;
            4'b1100: #3 R4 = D;
            4'b1101: #3 R5 = D;
            4'b1110: #3 R6 = D;
            4'b1111: #3 R7 = D;
        endcase
    end

    assign #2 A =
        (addrA == 3'b000) ? R0 :
        (addrA == 3'b001) ? R1 :
        (addrA == 3'b010) ? R2 :
        (addrA == 3'b011) ? R3 :
        (addrA == 3'b100) ? R4 :
        (addrA == 3'b101) ? R5 :
        (addrA == 3'b110) ? R6 :
        R7;

    assign #2 B =
        (addrB == 3'b000) ? R0 :
        (addrB == 3'b001) ? R1 :
        (addrB == 3'b010) ? R2 :
        (addrB == 3'b011) ? R3 :
        (addrB == 3'b100) ? R4 :
        (addrB == 3'b101) ? R5 :
        (addrB == 3'b110) ? R6 :
        R7;

endmodule
