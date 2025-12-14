# Info
This core top level contains additional submodules. THe CPU core itself and the clock wizard IP exist as in the single issue, but in addition the Integrated Logic Analayzer (ILA) IP also exists. 
This submodule must also be reconfigured for your Vivado projects. 

CPU.v - Top Module when implementing the CPU that contains Vivado IPs and instantiation of the Multi_Issue_CPU verilog file

Multi_Issue_CPU - Verilog file that contains the instantiation of all CPU modules (Fetch, Decode, Execute, Memory, Writeback)

