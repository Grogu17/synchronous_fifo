# Synchronous FIFO Design and Verification using Verilog HDL

## Overview

This project implements a **Synchronous First-In First-Out (FIFO)** memory using Verilog HDL. A FIFO is a data storage structure that follows the First-In First-Out principle, in which the first data written is the first data read.

The design uses a single clock for both read and write operations. It is implemented using a 16-entry memory array with an 8-bit data width and is verified through simulation using a self-checking Verilog testbench in Xilinx Vivado.

## Design Specifications

| Parameter | Specification |
|---|---|
| FIFO Type | Synchronous FIFO |
| Data Width | 8 bits |
| FIFO Depth | 16 entries |
| Memory Organization | 16 × 8 bits |
| Write Pointer | 4 bits |
| Read Pointer | 4 bits |
| Occupancy Counter | 5 bits |
| Clock | Single clock |
| Reset | Synchronous, active-high |
| HDL | Verilog |
| Simulation Tool | Xilinx Vivado Simulator (XSim) |

## Design Architecture

The FIFO consists of the following components:

### 1. Memory Array
- Stores 16 data entries.
- Each entry is 8 bits wide.
- Data is written and read using the corresponding pointers.

### 2. Write Pointer
- Identifies the memory location where incoming data is stored.
- Increments after every accepted write operation.
- Wraps around automatically after reaching the last memory location.

### 3. Read Pointer
- Identifies the memory location from which data is retrieved.
- Increments after every accepted read operation.
- Supports circular buffer operation.

### 4. Occupancy Counter
- Tracks the number of entries currently stored in the FIFO.
- Ranges from 0 to 16.
- Increments during write-only operations.
- Decrements during read-only operations.
- Remains unchanged during simultaneous accepted read and write operations.

### 5. Full and Empty Flags
- **Full:** Asserted when the FIFO contains 16 entries.
- **Empty:** Asserted when the FIFO contains zero entries.

## Functional Features

- Synchronous read and write operations.
- Independent read and write enable signals.
- Full and empty status flag generation.
- FIFO occupancy tracking.
- Simultaneous read and write support.
- Circular read and write pointer operation.
- Synchronous active-high reset.
- Protection against writing when full and reading when empty.

### Simultaneous Read and Write Behavior

| FIFO Condition | Write Request | Read Request | Operation |
|---|---|---|---|
| Empty | 1 | 1 | Write accepted, read rejected |
| Partially Full | 1 | 1 | Both operations accepted |
| Full | 1 | 1 | Read accepted, write rejected |

## Verification and Simulation

The design is verified using a self-checking testbench with a reference FIFO model.

The testbench automatically checks:
- FIFO occupancy count.
- Full and empty flags.
- Read and write pointer positions.
- Output data correctness after valid read operations.

### Test Scenarios

1. Synchronous reset operation.
2. Basic write and read operations.
3. FIFO data ordering.
4. Read attempt while FIFO is empty.
5. Filling the FIFO to its maximum capacity.
6. Write attempt while FIFO is full.
7. Simultaneous read and write while full.
8. Simultaneous read and write during normal operation.
9. Complete FIFO readout.
10. Read and write pointer wraparound.
11. Reset while FIFO contains data.
12. Read attempt after reset.
13. Normal operation after reset.

### Simulation Result

**ALL TESTS PASSED**

The testbench uses an independent reference model to compare the expected FIFO behavior against the actual RTL implementation.

## Tools and Technologies

- Verilog HDL
- Xilinx Vivado
- Vivado XSim Simulator

## Repository Structure

```text
Synchronous-FIFO-Verilog/
│
├── rtl/
│   └── synchronous_fifo.v
│
├── testbench/
│   └── synchronous_fifo_tb.v
│
├── simulation/
│   ├── waveform.png
│   └── simulation_log.txt
│
├── docs/
│   └── block_diagram.png
│
└── README.md
```

## Future Scope

- FPGA implementation and hardware validation.
- Timing analysis with appropriate clock constraints.
- Parameterized FIFO architecture.
- Further verification using additional corner cases.

## Author

**Sanjana Adhikari**

B.Tech – Electronics and Communication Engineering
