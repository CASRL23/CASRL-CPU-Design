# Info
This core has one top level module called "CPU." This top level module contains two submodules, the Pipelined CPU core, and the clock wizard IP. After cloning the repository, the clock wizard IP must be reconfigured for the
Vivado project. 

CPU.v - Top Module when implementing the CPU that contains Vivado IPs and instantiation of the Pipeline_CPU verilog file

Pipeline_CPU - Verilog file that contains the instantiation of all CPU modules (Fetch, Decode, Execute, Memory, Writeback)



To use it properly,

there are a few branches there is main and there is partly-working-uart-test branch, from vscode or terminal how ever the person would like to test this currently, would pull that branch for testing. 
- Import each of the files from the sources folder and test folder into vivado.
- once imported set cpu_uart_test.v as top folder
- Make sure ROM has the loaded correct mem file. current mem files being tested is "simple_uart_poll.mem" is in.
- then for the next step do sysnthesize first to make sure luts are around 27000 at least.
- then do implementation for on an artix-7 fpga
- it does take 20-50 minutes depending on jobs used in vivado.