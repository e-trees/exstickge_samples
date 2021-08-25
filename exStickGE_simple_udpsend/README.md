# A simple example to send packets by using e7UDP/IP.

## Requirements

- Vivado 2020.1

## Build

```
vivado -mode batch -source create_project.tcl
```

After building, You can get `top.bit` in `prj/exstickge_simple_udpsend.runs/impl_1/top.bit`

If you want to see VHDL version, run the following.

```
vivado -mode batch -source create_project_vhdl.tcl
```

## Run
Configure your exStickGE by the generated bit file, and connect it to your host PC via GbE.

After that, run the test program.

```ruby
ruby software/recv.rb
```

You can get the following messages. 

```
...
Send: counter=2545792500, diff=125000009
Send: counter=2670792509, diff=125000009
Send: counter=2795792518, diff=125000009
Send: counter=2920792527, diff=125000009
Send: counter=3045792536, diff=125000009
Send: counter=3170792545, diff=125000009
Send: counter=3295792554, diff=125000009
Send: counter=3420792563, diff=125000009
...
```

This indicates that the FPGA sends UDP/IP packets constantly.
