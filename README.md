# FPGA implementation of Ben Eater's 8-bit breadboard computer

This is my humble attempt at implementing Ben Eater's 8-bit
breadboard computer in Verilog. For more details about the
design and physical hardware implementation of the computer,
please refer to the original Youtube [playlist](https://www.youtube.com/watch?v=HyznrdDSSGM&list=PLowKtXNTBypGqImE405J2565dvjafglHU).

## Building the code

To build and simulate the computer using [Verilator](https://www.veripool.org/wiki/verilator),
just type:

```shell
make
```

To clean the repository, type
```shell
make clean
```


## Numato Mimas V2 board
Inside `board\numato_mimas_v2` there are some files that can be used for
generating the bistream for the Numato Mimas V2 board.


Thank you Ben Eater for the awesome videos!!!
