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
  | Feature_based Method      |           |            |           |  5 even 0-4
 1| line buffer for FAST      | 6         | 640        | 24        | 12 even 5-16
 4| line buffer for BRIEF     | 30        | 640        | 8         | 60 odd  0-59
 3| FIFO for NMS              | 1         | 640        | 26        |  4 even 21-24
 2| FIFO for sin, cos         | 2         | 640        | 12        |  4 even 17-20
 5| desc in MATCH             | 8         | 512        | 32        | 16 even 25-40 +8*512*8
 6| desc in MATCH             | 8         | 512        | 32        | 16 even 41-56 +8*512*8
 7| point in MATCH            | 1         | 512        | 20        |  2 even 57-58
 8| point in MATCH            | 1         | 512        | 20        |  2 even 59-60
 9| depth in MATCH            | 1         | 512        | 16        |  2 even 61-62
10| depth in MATCH            | 1         | 512        | 16        |  2 odd  60-61
  | ------------------------- | --------- | ---------- | --------- |
  | Direct Method             |           |            |           |
  | line buffer for srcFrame  | 1         | 640        | 24        |
  | line buffer for dstFrame  | 126       | 320        | 24        |

  After integrated

  | usage                     | # of sram | sram words | sram bits |
  | ------------------------- | --------- | ---------- | --------- |
  | Feature_based Method      |           |            |           |
  | desc in MATCH             | 8         | 512        | 8         |
  | desc in MATCH             | 8         | 512        | 8         |
  | ------------------------- | --------- | ---------- | --------- |
  | Direct Method             |           |            |           |
  | line buffer for srcFrame  | 1         | 640        | 24        |
  | ------------------------- | --------- | ---------- | --------- |
  | Shared                    |           |            |           |
  | line buffer for dstFrame  | 126       | 320        | 24        |