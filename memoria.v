// Practica 4 de SEM
// Por Manuel Martinez-Almeida

module memoriaRAM (salida, data, addr, MW, clk);
    input [15:0] data, addr;
    input MW, clk;

    output [15:0] salida;
    reg [15:0] RAM [125:0];

    initial begin
        // Introducimos en la primera direccion de memoria de la RAM el numero
        // cuya raiz cuadrada queremos calcular.
        RAM[0] = 5*5;
    end

    always @ (posedge clk) begin
        if(MW == 1)
            RAM[addr] = #10 data;
    end

    assign #10 salida = RAM[addr];
endmodule


module memoraROM (salida, addr);
    input [15:0] addr;
    output [15:0] salida;

    reg [15:0] ROM [1023:0];

    assign #10 salida = ROM[addr];

    // Almacenamos el programa a ejecutar en la ROM.
    initial begin
        ROM[ 0] = 16'b1001100000000000;  // LDI R0 0             (R[D] <- OP)
        ROM[ 1] = 16'b0010000000000000;  // LD R0 R0             (R[D] <- M[R[A]])
        ROM[ 2] = 16'b1001100001000001;  // LDI R1 1             (R[D] <- OP)
        ROM[ 3] = 16'b1001100010000001;  // LDI R2 1             (R[D] <- OP)
        ROM[ 4] = 16'b0001110011000001;  // SHL R3 R1            (R[D] <- R[B]<<1)
        ROM[ 5] = 16'b0000011010011010;  // ADD1 R2 R3 R2        (R[D] <- R[A]+R[B]+1)
        ROM[ 6] = 16'b0000001001001000;  // INC R1 R1            (R[D] <- R[A]+1)
        ROM[ 7] = 16'b0000101011010000;  // SUB R3 R2 R0         (R[D] <- R[A]-R[B])
        ROM[ 8] = 16'b1100001111000100;  // BRN loop             (if N=1: PC <- PC + AD)
        ROM[ 9] = 16'b0000000000001000;  // MOVA R0 R1           (R[D] <- R[A])
        ROM[10] = 16'b0000000010001000;  // MOVA R2 R1           (R[D] <- R[A])
        ROM[11] = 16'b0000000011001000;  // MOVA R3 R1           (R[D] <- R[A])
        ROM[12] = 16'b0000000100001000;  // MOVA R4 R1           (R[D] <- R[A])
        ROM[13] = 16'b0000000101001000;  // MOVA R5 R1           (R[D] <- R[A])
        ROM[14] = 16'b0000000110001000;  // MOVA R6 R1           (R[D] <- R[A])
        ROM[15] = 16'b0000000111001000;  // MOVA R7 R1           (R[D] <- R[A])
        ROM[16] = 16'b1001100000000000;  // LDI R0 0             (R[D] <- OP)
        ROM[17] = 16'b1100011111000111;  // BRZ final            (if Z=1: PC <- PC + AD)
    end
endmodule
