# MODULES
| Module | Path | Function |
|---|---|---|
| `pipeline_reg` | `rtl/pipeline/pipeline_reg.sv` | IF1/IF2, IF/ID, ID/EX, EX/MEM, MEM/WB pipeline registers |
| `forwarding_unit` | `rtl/pipeline/forwarding_unit.sv` | EX/MEM and MEM/WB forwarding to EX stage |
| `hazard_unit` | `rtl/pipeline/hazard_unit.sv` | Load-use stall detection and control-flow flush |
