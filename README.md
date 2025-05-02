# Digital-Verification-using-SV-and-UVM
**Asynchronous FIFO Verification Project**

![Linux Logo](https://github.com/user-attachments/assets/5943868a-9cda-4ea9-bffc-44489401f924)

*Verified on Linux / QuestaSim*

## 1. Project Overview

This repository contains the verification environment and scripts for an **asynchronous FIFO** module, implemented in SystemVerilog and verified using both SV-based directed tests and a UVM-based environment. Two versions of the FIFO design are provided:

* **FIFO\_0.1.0**: Initial version containing known bugs.
* **FIFO\_1.0.0**: First corrected and fully verified version.

Verification was performed in a Linux environment using QuestaSim. Each environment can be run with multiple random seeds to ensure robustness.

## 2. Environment Setup

1. **Toolchain:**

   * QuestaSim simulator
   * GNU Make
2. **Operating System:**

   * Linux (Ubuntu 20.04+ recommended)
3. **Environment Variables:**

   ```bash
   # Point to the root of this FIFO project
   export FIFO_ROOT=$HOME/path/to/syn_fifo
   ```

Ensure that `$FIFO_ROOT` is set in environment variables before invoking any of the make targets.

## 3. Directory Structure

```
${FIFO_ROOT}/
├── design/                 # RTL design files
│   ├── FIFO_0.1v.sv
│   ├── FIFO_1.0.0v.sv
├── sv_verification/       # SV-based directed testbench and scripts
│   ├── tb_fifo.sv
│   ├── src_files.list     # Generated file list for SV tests for FIFO_0.1v
│   ├── src_files_2.list   # Generated file list for SV tests for FIFO_1.0.0v
│   ├── FIFO_0.1v.sv
│   ├── FIFO_1.0.0v.sv
│   ├── FIFO_IF.sv
│   ├── FIFO_transaction_pkg.sv
│   ├── FIFO_coverage_pkg.sv
│   ├── FIFO_scoreboard_pkg.sv
│   ├── FIFO_monitor.sv
│   ├── FIFO_tb.sv
│   └── FIFO_top.sv
├── uvm_verification/       # UVM testbench and supporting classes
│   ├── Shared_pkg.sv      
│   ├── FIFO_v1.0.0.sv     
│   ├── FIFO_IF.sv        
│   ├── top_module.sv         
│   ├── FIFO_config_obj_pkg.sv         
│   ├── FIFO_test_pkg.sv        
│   ├── FIFO_sequence_pkg.sv         
│   ├── FIFO_env_pkg.sv         
│   ├── FIFO_coverage_pkg.sv        
│   ├── FIFO_sequence_item_pkg.sv         
│   ├── FIFO_sequencer_pkg.sv
│   ├── FIFO_agent_pkg.sv
│   ├── FIFO_driver_pkg.sv
│   ├── FIFO_monitor_pkg.sv
│   ├── FIFO_scoreboard_pkg.sv       
│   └── src_files.list      # Generated file list for UVM tests
├── tools/
│   ├── sv/                 # Tools for SV-based verification
│   │   ├── Makefile        # Targets to run SV tests with seeds
│   └── uvm/                # Tools for UVM-based verification
│       ├── Makefile        # Targets to run UVM tests with seeds
└── 
```

## 4. File Lists

Before running either environment, generate or update the file lists to include the RTL, testbench, and UVM class files.

1. **SV Verification file list:**

   ```bash
   find ${FIFO_ROOT}/design -name "*.sv" > ${FIFO_ROOT}/sv_verification/src_files.list
   find ${FIFO_ROOT}/design -name "*.sv" > ${FIFO_ROOT}/sv_verification/src_files_2.list
   ```

2. **UVM Verification file list:**

   ```bash
   find ${FIFO_ROOT}/uvm_verification -name "*.sv" >> ${FIFO_ROOT}/uvn_verification/src_files.list
   ```

Adjust paths in `src_files.list` as needed by your simulation scripts or Makefiles.

## 5. Running SV-Based Verification

The SV-based environment comprises directed test cases in `sv_verification/`. To run all tests with 5 different random seeds:

**Makefile targets:**

* "  questa        - Run basic simulation"
* "  questa+SIM    - Run simulation with +SIM defined"
* "  seed<number>  - Run simulation with specific seed (e.g., seed1, seed2)"
* "  all_seeds     - Run simulations with all predefined seeds"
* "  merge_coverage- Merge coverage data from all seed runs"
* "  run_seeds     - Run all seeds and merge coverage"
* "  clean         - Clean up simulation files"

Results, coverage reports, Logs and waveform dumps will be output into `sv_verification`.

## 6. Running UVM-Based Verification

The UVM environment provides a reusable testbench with sequences in `uvm_verification/`. To execute the UVM tests:

**Makefile targets:**

* "  questa        - Run basic simulation"
* "  questa+SIM    - Run simulation with +SIM defined"
* "  seed<number>  - Run simulation with specific seed (e.g., seed1, seed2)"
* "  all_seeds     - Run simulations with all predefined seeds"
* "  merge_coverage- Merge coverage data from all seed runs"
* "  run_seeds     - Run all seeds and merge coverage"
* "  clean         - Clean up simulation files"	

Results, coverage reports, and logs will be generated under `uvm_verification`.

## 7. Design Versions

Two tagged versions are available:

| Tag          | Description                  |
| ------------ | ---------------------------- |
| `FIFO_0.1.0` | Initial buggy version        |
| `FIFO_1.0.0` | Corrected & verified version |

Checkout a specific version before running tests:

```bash
git checkout tags/FIFO_1.0.0
```

## 8. Contributing & Extensions

* To add new test cases (SV or UVM), place your `.sv` files in the respective directories and update `src_files.list`.
* To increase the number of seeds, edit the `SEEDS` variable in `tools/*/Makefile`.

## 9. Authors

**Authors:**

* Your Name (`Mohamed Ahmed`)

Happy verifying! 🔍
