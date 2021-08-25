# A simple example to receive packets by using e7UDP/IP.

## Requirements

- Vivado 2020.1

## Build

```
vivado -mode batch -source create_project.tcl
```

After building, You can get `top.bit` in `prj/exstickge_simple_udprecv.runs/impl_1/top.bit`

## Run
Configure your exStickGE by the generated bit file, and connect it to your host PC via GbE.

After that, run the test program.

```ruby
ruby software/sendrecv.rb
```

You can get the following messages. 

```
Sum:: 55
```

This indicates that the FPGA receives the sent packet and makes summation of payloads.

