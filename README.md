# Digital-Verification-using-SV-and-UVM
**Asynchronous FIFO Verification Project**

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

   * Linux (Ubuntu 22.04+ recommended)
3. **Environment Variables:**

   ```bash
   # Point to the root of this FIFO project
   export FIFO_ROOT=$HOME/path/to/fifo-verification
   ```

n\`\`\`

Ensure that `$FIFO_ROOT` is set in environment pathes before invoking any of the make targets.

## 3. Directory Structure

```
${FIFO_ROOT}/
├── design/                 # RTL design files
│   ├── FIFO_0.1v.sv
│   ├── FIFO_1.0.0v.sv
├── sv_verification/       # SV-based directed testbench and scripts
│   ├── tb_fifo.sv
│   ├── src_files.list     # Generated file list for SV tests
│   ├── src_files_2.list
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

1. **Design file list:**

   ```bash
   find ${FIFO_ROOT}/design -name "*.sv" > ${FIFO_ROOT}/design/filelist.f
   ```

2. **SV Verification file list:**

   ```bash
   find ${FIFO_ROOT}/sv_verification -name "*.sv" >> ${FIFO_ROOT}/design/filelist.f
   ```

3. **UVM Verification file list:**

   ```bash
   find ${FIFO_ROOT}/uvm_verification -name "*.sv" >> ${FIFO_ROOT}/design/filelist.f
   ```

Adjust paths in `filelist.f` as needed by your simulation scripts or Makefiles.

## 5. Running SV-Based Verification

The SV-based environment comprises directed test cases in `sv_verification/`. To run all tests with 5 different random seeds:

```bash
cd ${FIFO_ROOT}/tools/sv
# By default, the Makefile uses SEED1…SEED5
make all
```

**Makefile targets:**

* `all` : Run tests for seeds 1..5
* `seed SEED=<n>` : Run only for the specified seed

Logs and waveform dumps will be output into `sv_verification/results/`.

## 6. Running UVM-Based Verification

The UVM environment provides a reusable testbench with sequences in `uvm_verification/`. To execute the UVM tests:

```bash
cd ${FIFO_ROOT}/tools/uvm
# By default, runs 5 seeds
make all
```

**Makefile targets:**

* `all`       : Run UVM tests for SEED1..SEED5
* `run SEED=n`: Run UVM test with a specific random seed

Results, coverage reports, and logs will be generated under `uvm_verification/results/`.

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
* To increase the number of seeds, edit the `SEED` variable in `tools/*/Makefile`.

## 9. License & Authors

This project is licensed under the MIT License.

**Authors:**

* Your Name (`Mohamed Ahmed`)
* Collaboration Team

Happy verifying! 🔍
