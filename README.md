Top module: CHIP_All.sv
testbench: Debug_tb_CHIP_All.sv

RTL simulation:

```
ncverilog Debug_tb_CHIP_All.sv +incdir+/opt/CAD/synopsys/synthesis/2019.12/dw/sim_ver/ -y /opt/CAD/synopsys/synthesis/2019.12/dw/sim_ver +libext+.v +notimingchecks +define+RTL +access+r 
```

or just...

```
sh Debug.sh
```



sram generate list

| usage                     | # of sram | sram words | sram bits |
| ------------------------- | --------- | ---------- | --------- |
| Feature_based Method      |           |            |           |
| line buffer for FAST      | 6         | 640        | 24        |
| line buffer for BRIEF     | 30        | 640        | 8         |
| FIFO for NMS              | 1         | 640        | 26        |
| FIFO for sin, cos         | 2         | 640        | 12        |
| desc in MATCH             | 16        | 512        | 32        |
| point in MATCH            | 2         | 512        | 20        |
| depth in MATCH            | 2         | 512        | 16        |
| ------------------------- | --------- | ---------- | --------- |
| Direct Method             |           |            |           |
| line buffer for srcFrame  | 1         | 640        | 24        |
| line buffer for dstFrame  | 126       | 320        | 24        |