# arty-glitcher

## FPGA-based glitcher for the Digilent Arty FPGA development board.

Files required for building the bitstream:
* src/top.v
* src/cmd.v
* src/delay.v
* src/fifo_arty.v
* src/pattern.v
* src/pulse.v
* src/resetter.v
* src/top_passthrough.v
* src/trigger.v
* src/uart_defs.v
* src/uart_rx.v
* src/uart_tx.v

You will need to include the FIFO as an existing IP block:
* syn/fifo_generator_0.xci

Finally, add the constraint file.
* create mode 100644 syn/Arty_Master.xdc

The pinout on the board is as follows:
* `IO[26]`: board1_rx - UART rx
* `IO[27]`: board1_tx - UART tx
* `IO[27]`: board1_rst - target reset, connect to the JTAG reset pin
* `IO[34]`: vout voltage select signal

The python control script is in the python directory:
* python/assignment5.py
