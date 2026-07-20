# ==============================================================================
all: compile compile_log_err sim simulate_log_err

# ==============================================================================
# Environment Variables & Include Directories
# ==============================================================================
AXI_VIP_DIR = ./axi_avip
RTL_DIR     = ../rtl
VLOG        = vlog
VSIM        = vsim

# Clean, unbroken include path (no trailing spaces!)
INC_DIR = +incdir+$(AXI_VIP_DIR)/globals+$(AXI_VIP_DIR)/hvl_top/master+$(AXI_VIP_DIR)/hvl_top/slave+./cpu_active_agent+./cpu_passive_agent+./interface+$(RTL_DIR)

# ==============================================================================
# Compilation Targets
# ==============================================================================
compile:
	
	# ---------------------------------------------------------
	# 1. Compile AXI VIP
	# ---------------------------------------------------------
	
	$(VLOG) -sv -work work $(INC_DIR) $(AXI_VIP_DIR)/globals/axi4_globals_pkg.sv
	$(VLOG) -sv -work work $(INC_DIR) $(AXI_VIP_DIR)/hvl_top/master/axi4_master_pkg.sv
	$(VLOG) -sv -work work $(INC_DIR) $(AXI_VIP_DIR)/hvl_top/slave/axi4_slave_pkg.sv
	
	# Full AXI BFM Set
	$(VLOG) -sv -work work $(INC_DIR) $(AXI_VIP_DIR)/hdl_top/master_agent_bfm/axi4_master_agent_bfm.sv
	$(VLOG) -sv -work work $(INC_DIR) $(AXI_VIP_DIR)/hdl_top/master_agent_bfm/axi4_master_driver_bfm.sv
	$(VLOG) -sv -work work $(INC_DIR) $(AXI_VIP_DIR)/hdl_top/master_agent_bfm/axi4_master_monitor_bfm.sv
	$(VLOG) -sv -work work $(INC_DIR) $(AXI_VIP_DIR)/hdl_top/slave_agent_bfm/axi4_slave_agent_bfm.sv
	$(VLOG) -sv -work work $(INC_DIR) $(AXI_VIP_DIR)/hdl_top/slave_agent_bfm/axi4_slave_driver_bfm.sv
	$(VLOG) -sv -work work $(INC_DIR) $(AXI_VIP_DIR)/hdl_top/slave_agent_bfm/axi4_slave_monitor_bfm.sv
	$(VLOG) -sv -work work $(INC_DIR) $(AXI_VIP_DIR)/hdl_top/axi4_interface/axi4_if.sv
	
	# ---------------------------------------------------------
	# 2. Compile Custom Packages & Interfaces
	# ---------------------------------------------------------
	#
	$(VLOG) -sv -work work $(INC_DIR) ./cpu_packages.sv
	$(VLOG) -sv -work work $(INC_DIR) ./axi_fifo_packages.sv
	#$(VLOG) -sv -work work $(INC_DIR) ./interface/axi4_interface.sv
	$(VLOG) -sv -work work $(INC_DIR) ./interface/fifo_interface.sv
	
	# ---------------------------------------------------------
	# 3. Compile RTL Packages 
	# ---------------------------------------------------------
	#
	# $(VLOG) -v -work work $(INC_DIR) ./AXI_MASTER_READ_CONTROL.v
	# $(VLOG) -v -work work $(INC_DIR) ./AXI_MASTER_WRITE_CONTROL.v
	# $(VLOG) -v -work work $(INC_DIR) ./AXI_Master.v
	# $(VLOG) -v -work work $(INC_DIR) ./write_response_handler.v
	# $(VLOG) -v -work work $(INC_DIR) ./decoder.v
	# $(VLOG) -v -work work $(INC_DIR) ./sync_fifo.v
	# $(VLOG) -v -work work $(INC_DIR) ./design_fifo.v	
	$(VLOG) -work work $(RTL_DIR)/axi_fifo_design.v

	# ---------------------------------------------------------
	# 4. Compile Top
	# --------------------------------------------------------
	#
	$(VLOG) -sv -l top.log -work work $(INC_DIR) ./axi_fifo_top.sv

sim:
	$(VSIM) -c -voptargs="+acc" -l simulation.log -do "log -r /*; run -all; quit -f" -L work +UVM_TESTNAME=axi_fifo_base_test work.top

clean:
	rm -rf work modelsim.ini transcript vsim.wlf vsim_stacktrace.vstf top.log simulation.log wave.vcd

compile_log_err:
	@echo ""
	@echo "-----------------------------------------------------------------"
	@echo "------------------- Compilation Report --------------------------"
	@echo ""
	@echo " Detailed Errors:"
	@grep -i "\*\* at" top.log || echo "No Errors found"
	@echo ""
	@echo " Summary:"
	@grep -i "^Errors:" top.log || echo "Summary not found"
	@echo ""
	@echo "Log file path: top.log"
	@echo ""
	@echo "-----------------------------------------------------------------"
	@echo "-----------------------------------------------------------------"
	@echo ""

simulate_log_err:
	@echo ""
	@echo "------------------------------------------------------------"
	@echo "-------------------- Simulation Report ---------------------"
	@echo ""
	@echo "UVM Fatal"
	@grep "FATAL" simulation.log || echo "No UVM_FATAL"
	@echo ""
	@echo "UVM Errors"
	@grep "ERROR" simulation.log || echo "No UVM_ERROR"
	@echo ""
	@echo "UVM Warnings"
	@grep "WARNING" simulation.log || echo "No UVM_WARNING"
	@echo ""
	@echo "Waveform: vsim -view waveform.wlf &"
	@echo "------------------------------------------------------------"
	@echo ""
