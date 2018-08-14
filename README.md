# Feather
A single cycle processor implementing a subset of the ARMv7 ISA.

## Motivation
Apart from being a very interesting side project, Feather is a proof-of-concept CPU designed and simulated at the RTL level using solely open source software.

## Dependencies
Feather is designed to be simulated with Verilator, an open source SystemVerilog-to-C++ translator, enabling high performance simulation. Apart from Verilator, you may want to install yosys, if you wish to run the synthesis script, and dot to render the resulting diagrams.

## Getting started
After cloning the repository and installing verilator (and obviously a C++ compiler and the essential build utilities like make), you can `cd` into the `bench` directory and run

```
make verify-<module-name>
```

This will build the C++ model for that model and run the testbench.

To run the test program in `bench/tests/program1.s`, you can type:

```
make verify-core
```

The results will be saved in the `out.vcd` file.

To run your own programs, you can use a website like [http://armconverter.com] to generate the hex code and then write it in little-endian format in the `program1.hex` file, which is what the simulator actually reads. Alternatively, you can use any ARM assembler and extract the binary encoding from there.

At the moment only data processing instructions are supported.