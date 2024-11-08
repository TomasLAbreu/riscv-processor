## Overview
It is intended to build a 32-bit:

- pipeline RISC-V processor;

## Tools
- [Online RISC-V Interpreter](https://www.cs.cornell.edu/courses/cs3410/2019sp/riscv/interpreter/)
- [Online RISC-V Assembler](https://riscvasm.lucasteske.dev/#)

## Setup
Firstly, clone the repo:
```
$ git clone git@github.com:TomasLAbreu/riscv-processor.git
$ cd riscv-processor/
```
## Support Documents
- [RISC-V Instruction Set Specifications](https://msyksphinz-self.github.io/riscv-isadoc/html/index.html)
- [RISC-V Instruction Set Manual](https://github.com/TomasLAbreu/riscv-processor/blob/main/doc/riscv-spec-20191213.pdf)
- [RISC-V Instruction Set Summary](https://github.com/TomasLAbreu/riscv-processor/blob/main/doc/RISC-V-Instruction-Set-Summary.pdf)
- [RISC-V Reference Card](https://github.com/TomasLAbreu/riscv-processor/blob/main/doc/RISC-V_referenceCard.pdf)
- [Digital Design and Computer Architecture RISC-V Edition](https://github.com/TomasLAbreu/riscv-processor/blob/main/doc/Digital-Design-And-Computer-Architecture-RISC-V-Edition.pdf) - Chapter 7 (PDF pages 421-470)

# Pipeline Processor

### Datapath, Control Unit and Hazard Unit Diagram
![Datapath_SC_Diagram](doc/diagrams/Pipeline_Design_Datapath_HazardUnit.png)


# Supported instructions:
The RISC-V core supports the following ISA instructions:

**I Type**
- [x] lb
- [x] lh
- [x] lw
- [x] lbu
- [x] lhu
- [x] addi
- [x] slli
- [x] slti
- [x] sltiu
- [x] xori
- [x] srli
- [x] srai
- [x] ori
- [x] andi
- [x] jalr

---
**S Type**
- [x] sb
- [x] sh
- [x] sw

---
**R Type**
- [x] add
- [x] sub
- [x] sll
- [x] slt
- [x] sltu
- [x] xor
- [x] srl
- [x] sra
- [x] or
- [x] and

---
**U Type**
- [x] auipc
- [x] lui

---
**B Type**
- [x] beq
- [x] bne
- [x] blt
- [x] bge
- [x] bltu
- [x] bgeu

---
**J Type**
- [x] jal


