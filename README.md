# Feather
A single cycle processor implementing a subset of the ARMv7 ISA.

## Motivation
Apart from being a very interesting side project, Feather is a proof-of-concept CPU designed and simulated at the RTL level using solely open source software. 

## Dependencies
Feather is designed to be simulated with Verilator, an open source SystemVerilog-to-C translator, enabling high performance simulation. Apart from Verilator, you may want to install yosys, if you wish to run the synthesis script, and dot to render the resulting diagrams.

## Getting started
After cloning the repository and installing verilator (and obviously a C++ compiler and the essential build utilities like make), you can `cd` into the `bench` directory and run

```
make <module-name>
```

This will build the C++ model and the testbench for that module.
To run the simulation/verification, you can then type

```
sim_<module-name>/V<module-name>
```

For instance, `make alu && sim_alu/Valu` to test the ALU.
