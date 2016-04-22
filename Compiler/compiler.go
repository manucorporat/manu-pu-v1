// Practica 4 de SEM
// Por Manuel Martinez-Almeida

package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"log"
	"os"
	"strconv"
	"strings"
)

const (
	TypeRegistro3 = iota
	TypeRegistro2DA
	TypeRegistro2DB
	TypeRegistro2AB
	TypeRegistro1A
	TypeControl0
	TypeInmediato2D_OP
	TypeInmediato3DA_OP
	TypeSalto
)

type (
	Instruction struct {
		Name        string
		Opcode      string
		Format      int
		Descripcion string
	}

	InstructionSet []Instruction

	Register struct {
		Name string
		Code string
	}

	RegisterSet []Register

	Assembler struct {
		Instructions InstructionSet
		Registers    RegisterSet
		buffer       bytes.Buffer
		flags        map[string]int
	}
)

func (s RegisterSet) Lookup(name string) Register {
	name = strings.ToUpper(name)
	for _, reg := range s {
		if reg.Name == name {
			return reg
		}
	}
	panic("unknown register " + name)
}

func (s InstructionSet) Lookup(name string) Instruction {
	name = strings.ToUpper(name)
	for _, inst := range s {
		if inst.Name == name {
			return inst
		}
	}
	panic("unknown opcode " + name)
}

func (a *Assembler) config() {
	newSet := make(InstructionSet, len(a.Instructions))
	for i, inst := range a.Instructions {
		newSet[i].Name = strings.ToUpper(strings.TrimSpace(inst.Name))
		newSet[i].Format = inst.Format
		newSet[i].Opcode = strings.Replace(inst.Opcode, " ", "", -1)
		newSet[i].Descripcion = inst.Descripcion
	}
	a.Instructions = newSet
}

func (a *Assembler) Compile(file io.Reader) {
	a.config()

	scanner := bufio.NewScanner(file)
	a.buffer.Reset()
	a.flags = make(map[string]int)
	index := 0
	lineNu := 1
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		index = a.parseLine(index, lineNu, line)
		lineNu++
	}
}

func (a *Assembler) registerFlag(name string, pos int) {
	_, ok := a.flags[name]
	if ok {
		panic("flag " + name + " was already registered")
	}
	a.flags[name] = pos
}

func (a *Assembler) lookupFlag(name string) int {
	pos, ok := a.flags[name]
	if !ok {
		panic("flag " + name + " is not registered")
	}
	return pos
}

func (a *Assembler) parseLine(index int, lineNu int, line string) int {
	defer func() {
		if err := recover(); err != nil {
			log.Fatalf("[ERROR] %v :: line %d: %s", err, lineNu, line)
		}
	}()

	parts := strings.Fields(line)
	if len(parts) == 0 {
		return index
	}
	opcode := parts[0]
	if opcode[0] == ';' {
		return index
	}
	if opcode[len(opcode)-1] == ':' {
		flagName := opcode[:len(opcode)-1]
		a.registerFlag(flagName, index)
		return index
	}
	instruction := a.Instructions.Lookup(opcode)

	addrD := "000"
	addrA := "000"
	addrB := "000"

	switch instruction.Format {
	case TypeRegistro3:
		mustLen(parts, 4)
		addrD = a.Registers.Lookup(parts[1]).Code
		addrA = a.Registers.Lookup(parts[2]).Code
		addrB = a.Registers.Lookup(parts[3]).Code
	case TypeRegistro2DA:
		mustLen(parts, 3)
		addrD = a.Registers.Lookup(parts[1]).Code
		addrA = a.Registers.Lookup(parts[2]).Code
	case TypeRegistro2DB:
		mustLen(parts, 3)
		addrD = a.Registers.Lookup(parts[1]).Code
		addrB = a.Registers.Lookup(parts[2]).Code
	case TypeRegistro2AB:
		mustLen(parts, 3)
		addrA = a.Registers.Lookup(parts[1]).Code
		addrB = a.Registers.Lookup(parts[2]).Code
	case TypeRegistro1A:
		mustLen(parts, 2)
		addrA = a.Registers.Lookup(parts[1]).Code
	case TypeControl0:
		mustLen(parts, 1)
	case TypeInmediato2D_OP:
		mustLen(parts, 3)
		addrD = a.Registers.Lookup(parts[1]).Code
		addrB = intToBin(parts[2])
	case TypeInmediato3DA_OP:
		mustLen(parts, 3)
		addrD = a.Registers.Lookup(parts[1]).Code
		addrA = a.Registers.Lookup(parts[2]).Code
		addrB = intToBin(parts[3])
	case TypeSalto:
		mustLen(parts, 2)
		diff := a.lookupFlag(parts[1]) - index
		addrD, addrB = intToAD(diff)
	default:
		panic("unknown instruction format")
	}

	code := instruction.Opcode + addrD + addrA + addrB
	if len(code) != 16 {
		panic("BUG!! instruction MUST be 16 bits. internal error")
	}
	fmt.Fprintf(&a.buffer, "ROM[%2d] = 16'b%s;  // %-20s (%s)\n",
		index, code, strings.TrimSpace(line), instruction.Descripcion)

	return index + 1
}

func NewAssembler() *Assembler {
	assembler := &Assembler{
		Instructions: InstructionSet{
			{"MOVA", "000 0000", TypeRegistro2DA, "R[D] <- R[A]"},
			{"INC ", "000 0001", TypeRegistro2DA, "R[D] <- R[A]+1"},
			{"ADD ", "000 0010", TypeRegistro3, "R[D] <- R[A]+R[B]"},
			{"ADD1", "000 0011", TypeRegistro3, "R[D] <- R[A]+R[B]+1"},
			{"SUB ", "000 0101", TypeRegistro3, "R[D] <- R[A]-R[B]"},
			{"DEC ", "000 0110", TypeRegistro2DA, "R[D] <- R[A]-1"},
			{"AND ", "000 1000", TypeRegistro3, "R[D] <- R[A]&R[B]"},
			{"OR  ", "000 1001", TypeRegistro3, "R[D] <- R[A]|R[B]"},
			{"XOR ", "000 1010", TypeRegistro3, "R[D] <- R[A]^R[B]"},
			{"NOT ", "000 1011", TypeRegistro2DA, "R[D] <- ~R[A]"},
			{"MOVB", "000 1100", TypeRegistro2DB, "R[D] <- R[B]"},
			{"SHR ", "000 1101", TypeRegistro2DB, "R[D] <- R[B]>>1"},
			{"SHL ", "000 1110", TypeRegistro2DB, "R[D] <- R[B]<<1"},

			{"LDI ", "100 1100", TypeInmediato2D_OP, "R[D] <- OP"},
			{"ADI ", "100 0010", TypeInmediato3DA_OP, "R[D] <- R[A]+OP"},

			{"LD  ", "001 0000", TypeRegistro2DA, "R[D] <- M[R[A]]"},
			{"ST  ", "010 0000", TypeRegistro2AB, "M[R[A]] <- R[B]"},

			{"BRZ ", "110 0000", TypeSalto, "if Z=1: PC <- PC + AD"},
			{"BRN ", "110 0001", TypeSalto, "if N=1: PC <- PC + AD"},
			{"BRZN", "110 0010", TypeSalto, "if Z=0: PC <- PC + AD"},
			{"BRNN", "110 0011", TypeSalto, "if N=0: PC <- PC + AD"},

			{"JMP ", "111 0001", TypeRegistro1A, "PC <- R[A]"},
			{"HALT", "110 1111", TypeControl0, "PC <- PC (halt)"},
		},

		Registers: RegisterSet{
			{"R0", "000"},
			{"R1", "001"},
			{"R2", "010"},
			{"R3", "011"},
			{"R4", "100"},
			{"R5", "101"},
			{"R6", "110"},
			{"R7", "111"},
		},
	}
	return assembler
}

func main() {
	argsWithoutProg := os.Args[1:]
	log.SetFlags(0)
	if len(argsWithoutProg) != 1 {
		log.Fatal("bad command line input")
	}
	filename := argsWithoutProg[0]
	file, err := os.Open(filename)
	if err != nil {
		log.Fatal(err)
	}

	assembler := NewAssembler()
	assembler.Compile(file)
	fmt.Println(assembler.buffer.String())
}

func mustLen(array []string, length int) {
	if len(array) != length {
		log.Fatalf("expected %d params, got %d", length, len(array))
	}
}

func intToBin(nu string) string {
	integer, err := strconv.ParseInt(nu, 10, 64)
	if err != nil {
		log.Fatal(err)
	}
	bits := uint(3 - 1)
	upperLimit := int64((1 << bits) - 1)
	lowerLimit := int64(-upperLimit + 1)
	if integer > upperLimit || integer < lowerLimit {
		panic("immediate value out of bounds")
	}
	out := fmt.Sprintf("%03b", uint(integer))
	return out[len(out)-3:]
}

func intToAD(integer int) (string, string) {
	bits := uint(6 - 1)
	upperLimit := int((1 << bits) - 1)
	lowerLimit := int(-upperLimit + 1)
	if integer > upperLimit || integer < lowerLimit {
		panic("AD out of bounds")
	}
	out := fmt.Sprintf("%06b", uint(integer))
	return out[len(out)-6 : len(out)-3], out[len(out)-3:]
}
