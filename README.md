Top module: CHIP_Direct.sv
testbench: Debug_tb_CHIP_Direct.sv

RTL simulation:

```
ncverilog Debug_tb_CHIP_Direct.sv +incdir+/opt/CAD/synopsys/synthesis/2019.12/dw/sim_ver/ -y /opt/CAD/synopsys/synthesis/2019.12/dw/sim_ver +libext+.v +notimingchecks +define+RTL +access+r 
```

or just...

```
sh Debug.sh
```



sram generate list

| usage                     | # of sram | sram words | sram bits |
| ------------------------- | --------- | ---------- | --------- |
| line buffer for srcFrame  | 1         | 640        | 24        |
| line buffer for dstFrame  | 126       | 320        | 24        |