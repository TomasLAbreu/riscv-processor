#-------------------------------------------------------------------------------
#
# Author: Tomas Abreu
#
# Date(yyyy-mm-dd): 2024-04-14
#
# Description:
#   Makefile for launching Xilinx Vivado services by command line:
#			Compilation+Simulation+WaveViewer+Synthesis??
#-------------------------------------------------------------------------------

include configs.mk

rtl_dir  = $(proj_dir)/src
sim_dir  = $(proj_dir)/sim/testbench

work_dir = $(proj_dir)/WORK

#-------------------------------------------------------------------------------
rtl_src = -f $(rtl_dir)/riscv_pipeline.lst
rtl_src+= --include $(rtl_dir)
# rtl_src+= --define my_macro=1

sim_src = ${sim_dir}/*.sv

#-------------------------------------------------------------------------------
sim_top_tb  = tb
sim_snapshot= ${sim_top_tb}_snapshot
sim_wcfg 		= ${sim_snapshot}.wcfg
sim_wdb 		= ${sim_snapshot}.wdb
sim_vcd     = dump.vcd

comp_log = comp.log
elab_log = elab.log
sim_log  = sim.log

#-------------------------------------------------------------------------------
.PHONY: run comp sim wave

run: comp sim ## Compile design and Run simulation

comp: ## Compile design
	@$(call print_rule, "Compiling source files")
	@mkdir -p $(work_dir)
	cd $(work_dir); \
	$(XVLOG) ${rtl_src} | tee $(comp_log); \
	$(XVLOG) --sv $(defines) ${sim_src} | tee -a $(comp_log)
	cd $(work_dir); \
	$(XELAB) -debug all -top ${sim_top_tb} -snapshot ${sim_snapshot} | tee -a $(comp_log)
	@echo "\n${CYAN}---> Grep through compilation logs:${RST}\n"
	@$(call ignore_comp_infos, $(work_dir)/$(comp_log)); \
	if [ $$? -ne 1 ]; then \
		exit 1; \
	fi

sim: ## Run simulation
	@$(call print_rule, "Run simulation")
	cd $(work_dir); \
	$(XSIM) ${sim_snapshot} --tclbatch ${proj_dir}/xsim_cfg.tcl --wdb ${sim_wdb} -log ${sim_log}
# 	$(XSIM) ${sim_snapshot} --wdb ${sim_wdb} --R --log ${sim_log}

# --cov_db_dir
wave:
	@$(call print_rule, "Show sim waveforms")
	cd $(work_dir); \
	$(XSIM) --gui ${sim_wdb} --view $(proj_dir)/sim/scripts/$(sim_wcfg) 2> /dev/null &

#-------------------------------------------------------------------------------
# GUI

# vivado:
# 	@$(call print_rule, "Open vivado for package IP")
# 	cd $(work_dir); \
# 	vivado proj.xpr &

# requires tclbatch with log_wave ??
# wave: ## Display simulation waveforms
# 	@$(call print_rule, "Display Vivado Waveforms")
# 	@echo "Opening Vivado in the background..."
# 	@cd $(work_dir); \
# 	$(XSIM) --gui ${sim_snapshot}.wdb --tclbatch ../create_gui_cmd.tcl \
# 		--view ${sim_snapshot}.wcfg 2> /dev/null &

# requires tclbatch with open_vcd/log_vcd *

gtk:
ifneq ("$(wildcard $(work_dir)/$(sim_vcd))", "")
	cd $(work_dir); \
	gtkwave $(sim_vcd) 2> /dev/null &
else
	$(error "$(sim_vcd)" does not exist)
endif

#-------------------------------------------------------------------------------
# Administrative targets

.PHONY: clean help

.setup:

clean:
	@$(call print_rule, "Cleaning WORK directory")
	@rm -rf $(work_dir)

# 	@echo "INFO: $(sim_snapshot).wcfg will be preserved"
# 	@find $(work_dir)/ ! -name '$(sim_snapshot).wcfg' -type f -exec rm -rf {} +
# 	@rm -rf *.log *.jou *.pb *.dir .Xil *.str

help: ## Generate list of targets with descriptions
	@$(call print_rule, "Print help")
	@$(call print_help)
