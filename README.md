# CASRL-CPU-Design
This repository serves as an archive of work done by the Fall 2025 Senior Design team. Below are a series of descriptions, build tips, suggestions for future work, and known issues.

# Repo Structure
This repository is divided into different directories for each core. This is because the ideal workflow uses **different Vivado projects** for each core. Different designs use different source files and Vivado will actu unpredicatbly when those files change or moove as when changing branches. It is strongly reccomended that individual Vivado projects are created and managed for each isntance of the core that one wishes to work on.

# Core information
All core designs in this repository implement the RV32I base instruction set, excluding memory fencing, multithreading, and environment call instructions. The list of excluded instructions is as follows:
 - csrrc
 - csrrci
 - csrrs
 - csrrsi
 - csrrwi
 - ecall
 - fence
 - fence.i

# Single Cycle
This directory includes the Verilog source files and testbench files for a single cycle core design. 

# Single Issue In-Order Pipeline
This directory includes the Verilog source files and testbench files for a 5-stage in-order pipeline implementation.
The pipeline stages are as follows: Instruction Fetch, Instruction Decode, Execute, Memory, Register writeback.

# Multi Issue In-Order Pipeline
This directory includes the Verilog source files and testbench files for a 5-stage 4-issue width in-order pipeline implementation. This implementation has the same pipeline stages as the single issue in-order pipeline, but the Instruction Fetch, Instruction Decode, Execute, and Register Writeback stages have an inssude width of four, The memory stage still have a single issue width.

# Single Issue Out-of-Order Pipeline

# Multi Issue Out-of-Order Pipeline

# Spur
Spur is the name of the shell program written targeting these core designs. This shell is written entirley in RISC-V assembly, and is intended to prove the following commands:

  ```clrs``` - Clear the terminal screen
  
  ```regm``` - Display the values of all architectural registers x0-x31
  
 ```fib```  - Calculate and display the first 20 fibbonacci numbers


