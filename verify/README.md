# LSU TEST  
### Testbench architecture  
![LSU TEST Architecture](../further/lsu_testbench.svg)  
### AXI BFM architecture
![AXI BFM Architecture](../further/bfm_architecture.svg)  
The BFM is spereated in 3 parts. Depending on the AXI-Lite mode 2 of them are activated:  
Manager-Mode: `axil_mon_bf` + `axil_mgr_bfm`  
Subordinate-Mode: `axil_mon_bf` + `axil_sub_bfm`  