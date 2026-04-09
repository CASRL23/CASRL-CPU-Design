# Info
This core has one top level module called "CPU." This top level module contains two submodules, the Pipelined CPU core, and the clock wizard IP. After cloning the repository, the clock wizard IP must be reconfigured for the
Vivado project. 

CPU.v - Top Module when implementing the CPU that contains Vivado IPs and instantiation of the Pipeline_CPU verilog file

Pipeline_CPU - Verilog file that contains the instantiation of all CPU modules (Fetch, Decode, Execute, Memory, Writeback)
