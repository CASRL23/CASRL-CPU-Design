# CASRL-CPU-Design
This repository serves as an archive of work done by the Fall 2025 Senior Design team. Below are a series of descriptions, build tips, suggestions for future work, and known issues.

# Repo Structure
This repository is divided into different directories for each core. This is because the ideal workflow uses **different Vivado projects** for each core. Different designs use different source files and Vivado will act unpredicatbly when those files change or moove as when changing branches. It is strongly reccomended that individual Vivado projects are created and managed for each isntance of the core that one wishes to work on.

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

# Running Software

Each processor core runs programs from a ROM that is initialized during synthesis. The program files are stored as `.mem` files, where each file contains the hex machine code for a specific test program.

Before running synthesis in Vivado, choose the correct program file for the processor core being tested. For example, select the proper `.mem` program from the folder for the desired architecture, such as:

- Single-Issue In-Order
- Multi-Issue In-Order
- Single-Issue Out-of-Order
- Multi-Issue Out-of-Order

After selecting the program, update the file name inside the ROM module. In `ROM.v`, the string inside the `$readmemh()` statement must match the `.mem` file being used.

Example:
```verilog```
$readmemh("programs.mem", memory);
### Note 
Vivado versions before 2025.2 do _not_ recognize changes in these .mem program files as changes that invalidate the current bitstream. If you are running Vivado 2025.1 or earlier, if you change the contents of a .mem file, you must manually click _Run Synthesis_. Vivado will then tell you that "Synthesis has already been run and is up to date" this is **_false_** and is a bug that has been fixed in version 2025.2
 
# archive folder
This folder is for projects that got disconnected from this github but is more upto date code from the lab pc so all files can be organized and updated to make sure everything functions.

# Single Cycle
This directory includes the Verilog source files and testbench files for a single cycle core design. 

# Single Issue In-Order Pipeline
This directory includes the Verilog source files and testbench files for a 5-stage in-order pipeline implementation.
The pipeline stages are as follows: Instruction Fetch, Instruction Decode, Execute, Memory, Register writeback.

# Multi Issue In-Order Pipeline
This directory includes the Verilog source files and testbench files for a 5-stage 4-issue width in-order pipeline implementation. This implementation has the same pipeline stages as the single issue in-order pipeline, but the Instruction Fetch, Instruction Decode, Execute, and Register Writeback stages have an issue width of four, The memory stage still have a single issue width.

# Single Issue Out-of-Order Pipeline
This directory includes sources and testbenches for OoO design being single width issue for the processor design. The design is based on tumasulo's algorithm for OoO design.

# Multi Issue Out-of-Order Pipeline
This directory is the 4-issue width of the tumasulo's algorithm for CPU design 
# Spur
Spur is the name of the shell program written targeting these core designs. This shell is written entirley in RISC-V assembly, and is intended to prove the following commands:

  ```clrs``` - Clear the terminal screen
  
  ```regm``` - Display the values of all architectural registers x0-x31
  
 ```fib```  - Calculate and display the first 20 fibbonacci numbers


