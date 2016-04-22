#Harvard Single Cycle CPU

Designed for learning purposes.

- Verilog: [Includes a simple complete implementation of the CPU in verilog.](https://github.com/manucorporat/manu-pu-v1/blob/master/unidad_funcional.v)
- Golang: [A single pass assembler (it does not support forward declarations of flags)](https://github.com/manucorporat/manu-pu-v1/blob/master/Compiler/compiler.go)

##Design

![](https://raw.githubusercontent.com/manucorporat/manu-pu-v1/master/Screen%20Shot%202016-04-22%20at%2019.04.54.png)

![](https://raw.githubusercontent.com/manucorporat/manu-pu-v1/master/Screen%20Shot%202016-04-22%20at%2019.05.14.png)


##Compile
```bash
cd Compiler/
go run compiler.go <ASSEMBLY_FILE.S>
```


it will output a text through stdout like:

```verilog
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
ROM[16] = 16'b1101111000000000;  // HALT                 (PC <- PC (halt))
```

That must be manually copied to `memory.v` inside the ROM module.

##Run
```bash
iverilog testbench.v
vvp a.out
open out.vcd
```
