
VSIM = vsim
RUN = run
VLOG = qverilog

# Define testbench Directory
TBDIR = ${FIFO_ROOT}/sv_verification

# Target flist
target = src_files
FLIST = ${target}.list

VPATH = $(TBDIR)
TBFILES = $(TBDIR)/$(FLIST)

# Define 5 seed values
SEEDS = 1111 1511 2515 2236 5215

# Targets
clean:
	rm -rf *.log *.dis *.tbl vcs* simv* *.map transcript *.ucdb *.wlf *.txt \
	work dataset.asdb  library.cfg work	

##################### Simulation Runs #####################################   
questa: ${TBFILES}
	$(VLOG) -l vlog.log -sv -mfcu -f ${TBFILES} +cover -covercells -R +nowarn3829
	$(VSIM) -voptargs=+acc work.FIFO_top -cover -do "do wave.do; coverage save FIFO.ucdb -onexit; run -all"
		
questa+SIM: ${TBFILES}
	$(VLOG) -l vlog.log -sv -mfcu -f ${TBFILES} +define+SIM +cover -covercells -R +nowarn3829
	$(VSIM) -voptargs=+acc work.FIFO_top -cover -do "do wave.do; coverage save FIFO.ucdb -onexit; run -all"
	
# Run simulation with a specific seed
seed%: ${TBFILES}
	@echo "Running simulation with seed $*"
	$(VLOG) -l vlog.log -sv -mfcu -f ${TBFILES} +define+SIM +cover +cover -covercells -R +nowarn3829
	$(VSIM) -voptargs=+acc work.FIFO_top -cover -sv_seed $* -do "do wave.do; coverage save FIFO_seed$*.ucdb -onexit; run -all"
	vcover report FIFO_seed$*.ucdb -details -annotate -all -output code_coverage_rpt_seed$*.txt -du=FIFO
	vcover report -details -cvg -output functional_coverage_report_seed$*.txt FIFO_seed$*.ucdb

# Run all seeds in sequence
all_seeds: ${TBFILES}
	@echo "Running simulations with all seeds"
	$(VLOG) -l vlog.log -sv -mfcu -f ${TBFILES} +define+SIM +cover +cover -covercells -R +nowarn3829
	@for seed in $(SEEDS); do \
		echo ""; \
		echo "Running simulation with seed $$seed"; \
		$(VSIM) -voptargs=+acc work.FIFO_top -cover -sv_seed $$seed -do "do wave.do; coverage save FIFO_seed$$seed.ucdb -onexit; run -all"; \
		vcover report FIFO_seed$$seed.ucdb -details -annotate -all -output code_coverage_rpt_seed$$seed.txt -du=FIFO; \
		vcover report -details -cvg -output functional_coverage_report_seed$$seed.txt FIFO_seed$$seed.ucdb; \
	done
	@echo "All seed runs completed"

# Merge coverage results from all seeds
merge_coverage: 
	@echo "Merging coverage from all seed runs"
	vcover merge merged.ucdb FIFO_seed*.ucdb
	$(VSIM) -c -do "coverage open merged.ucdb; coverage report -output merged_coverage_report.txt -srcfile=* -detail; quit -f"
	vcover report merged.ucdb -details -annotate -all -output merged_code_coverage_rpt.txt -du=FIFO
	vcover report -details -cvg -output merged_functional_coverage_report.txt merged.ucdb
	@echo "Coverage merged to merged.ucdb and reports saved"

# Run all seeds and merge coverage
run_seeds: all_seeds merge_coverage
	@echo "Complete seed-based simulation and coverage analysis finished"

help:
	@echo Make sure the environment variable FIFO_ROOT is set.
	@echo Possible targets:
	@echo "  questa        - Run basic simulation"
	@echo "  questa+SIM    - Run simulation with +SIM defined"
	@echo "  seed<number>  - Run simulation with specific seed (e.g., seed1, seed2)"
	@echo "  all_seeds     - Run simulations with all predefined seeds"
	@echo "  merge_coverage- Merge coverage data from all seed runs"
	@echo "  run_seeds     - Run all seeds and merge coverage"
	@echo "  clean         - Clean up simulation files"		
