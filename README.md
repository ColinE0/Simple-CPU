# Simple-CPU

A simple 16-bit CPU written in Verilog, built as a learning project. Single-address-space
(von Neumann) design with a 16-bit datapath, eight general-purpose registers, and a
16-bit fixed-width instruction encoding.

## Modules

| File | Purpose |
|------|---------|
| `cpu.v` | Top level: PC, instruction register, module wiring |
| `alu.v` | Arithmetic/logic unit (add, sub, mul, div, and, or, not, xor, mov) |
| `control_unit.v` | Instruction decoder and control signal generation |
| `register_file.v` | 8 x 16-bit register file |
| `memory.v` | 64K x 16 unified instruction/data memory, loaded from hex |
| `cpu_tb.v` | Testbench: runs the demo program and checks the ALU result |

## Instruction set

4-bit opcode in `[15:12]`: LOAD (immediate), STORE, ADD, SUB, MUL, DIV, AND, OR, NOT,
XOR, JUMP, HALT. Register fields are 3 bits each; LOAD/STORE carry a 9-bit immediate.

## Running the simulation

Requires [Icarus Verilog](https://steveicarus.github.io/iverilog/) and Python.

```sh
python pad_hex.py            # expands program.hex to the full 64K image
iverilog -o sim cpu_tb.v cpu.v alu.v control_unit.v memory.v register_file.v
vvp sim
```

## Status

Work in progress. The fetch path currently never asserts the memory read enable, so
instructions are not loaded into the IR and the demo program does not run to HALT yet.
