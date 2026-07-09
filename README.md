# Verilog RISC-V Processor

A 64-bit RISC-V (RV64I) processor implemented in Verilog featuring both a single-cycle processor and a 5-stage pipelined processor.

The project was developed as part of the **Introduction to Processor Architecture** course at IIIT Hyderabad.

---

## Features

### Single-Cycle Processor

- RV64I 64-bit datapath
- Register file (32 × 64-bit)
- ALU
- Immediate generator
- Control unit
- Instruction memory
- Data memory
- Branch execution (BEQ)
- Complete module-level testbenches

### Five-Stage Pipeline

- IF
- ID
- EX
- MEM
- WB

Pipeline support includes:

- Data forwarding
- Hazard detection
- Load-use stalls
- Control hazard handling
- MEM-to-MEM forwarding optimization

---

## Supported Instructions

| Category | Instructions |
|-----------|--------------|
| Arithmetic | add, sub |
| Logical | and, or |
| Immediate | addi |
| Memory | ld, sd |
| Branch | beq |

---

## Project Structure

```
.
├── single-cycle/
├── pipeline/
├── project_report.pdf
└── README.md
```

---

## Architecture

### Single-Cycle Datapath

- Program Counter
- Instruction Memory
- Register File
- Immediate Generator
- Control Unit
- ALU
- Data Memory
- Write-back Multiplexer

### Pipeline Stages

```
Instruction Fetch
        ↓
Instruction Decode
        ↓
Execute
        ↓
Memory Access
        ↓
Write Back
```

Pipeline registers:

- IF/ID
- ID/EX
- EX/MEM
- MEM/WB

---

## Hazard Handling

The pipelined implementation supports:

- EX → EX forwarding
- MEM → EX forwarding
- Load-use hazard detection
- One-cycle pipeline stalls
- MEM → MEM forwarding for load-store sequences

---

## Testing

Each hardware module was verified independently before system integration.

Verified components include:

- Program Counter
- Register File
- ALU
- ALU Control
- Immediate Generator
- Control Unit
- Data Memory
- Pipeline Registers
- Full Processor Integration

Simulation was performed using:

- Icarus Verilog
- GTKWave

---

## Results

Implemented both:

- Single-cycle RV64I processor
- Five-stage pipelined RV64I processor

with successful execution of supported instruction sequences and verification through simulation waveforms and automated testbenches.

---

## Technologies

- Verilog HDL
- Icarus Verilog
- GTKWave

---

## Documentation

The complete design, implementation details, verification methodology, and pipeline analysis are available in:

📄 **project_report.pdf**

---

## Authors

- Shriya Kansal
- Prathish Ghosh
- Kavya Veer
