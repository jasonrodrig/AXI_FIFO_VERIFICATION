QUESTA := /home/share/questa.csh
SHELL  := /bin/csh

.ONESHELL:
.SILENT:
#.SHELLFLAGS = -e
#===============================================================================
# Targets
#===============================================================================
.PHONY: all clean compile compile_log_err sim simulate_log_err
all: clean compile compile_log_err sim simulate_log_err

#===============================================================================
# Environment Variables
#===============================================================================
AXI_VIP_DIR = ./axi_avip
RTL_DIR     = ../rtl

VLOG = vlog:WQ

VSIM = vsim
COMPILE_LOG = compile.log

#===============================================================================
# Include Directories
#===============================================================================
INC_DIR = \
+incdir+$(RTL_DIR) \
+incdir+$(AXI_VIP_DIR)/globals \
+incdir+$(AXI_VIP_DIR)/hvl_top/master \
+incdir+$(AXI_VIP_DIR)/hvl_top/slave \
+incdir+./cpu/cpu_active_agent \
+incdir+./cpu/cpu_passive_agent \
+incdir+./cpu/cpu_sequence_item \
+incdir+./interface \
+incdir+./env \
+incdir+./sequence \
+incdir+./virtual_sequence \
+incdir+./test


#===============================================================================
# Compile
#===============================================================================
compile:
	
	echo "------------------------------------------------------------"
	echo "Compiling RTL Packages"
	echo "------------------------------------------------------------"
	echo ""
	
	$(VLOG) $(RTL_DIR)/AXI_Master.v >>& $(COMPILE_LOG)
	$(VLOG) $(RTL_DIR)/AXI_MASTER_WRITE_CONTROL.v >>& $(COMPILE_LOG)
	$(VLOG) $(RTL_DIR)/AXI_MASTER_READ_CONTROL.v >>& $(COMPILE_LOG)
	$(VLOG) $(RTL_DIR)/decoder.v >>& $(COMPILE_LOG)
	$(VLOG) $(RTL_DIR)/design_fifo.v >>& $(COMPILE_LOG)
	$(VLOG) $(RTL_DIR)/sync_fifo.v >>& $(COMPILE_LOG)
	$(VLOG) $(RTL_DIR)/write_response_handler.v >>& $(COMPILE_LOG)
	$(VLOG) $(RTL_DIR)/axi_fifo_design.v >>& $(COMPILE_LOG)
	
	echo "------------------------------------------------------------"
	echo "Compiling AXI VIP Packages"
	echo "------------------------------------------------------------"
	echo ""
	
	$(VLOG) -work work $(INC_DIR) $(AXI_VIP_DIR)/globals/axi4_globals_pkg.sv >>& $(COMPILE_LOG)
	$(CHECK_VLOG)
	$(VLOG) -work work $(INC_DIR) $(AXI_VIP_DIR)/hvl_top/master/axi4_master_pkg.sv >>& $(COMPILE_LOG)
	$(VLOG) -work work $(INC_DIR) $(AXI_VIP_DIR)/hvl_top/slave/axi4_slave_pkg.sv >>& $(COMPILE_LOG) 
	
	echo "------------------------------------------------------------"
	echo "Compiling AXI BFMs"
	echo "------------------------------------------------------------"
	echo ""
	
	$(VLOG) -work work $(INC_DIR) $(AXI_VIP_DIR)/hdl_top/master_agent_bfm/axi4_master_agent_bfm.sv >>& $(COMPILE_LOG)
	$(VLOG) -work work $(INC_DIR) $(AXI_VIP_DIR)/hdl_top/master_agent_bfm/axi4_master_driver_bfm.sv >>& $(COMPILE_LOG) 
	$(VLOG) -work work $(INC_DIR) $(AXI_VIP_DIR)/hdl_top/master_agent_bfm/axi4_master_monitor_bfm.sv >>& $(COMPILE_LOG) 
	
	$(VLOG) -work work $(INC_DIR) $(AXI_VIP_DIR)/hdl_top/slave_agent_bfm/axi4_slave_agent_bfm.sv >>& $(COMPILE_LOG) 
	$(VLOG) -work work $(INC_DIR) $(AXI_VIP_DIR)/hdl_top/slave_agent_bfm/axi4_slave_driver_bfm.sv >>& $(COMPILE_LOG)
	$(VLOG) -work work $(INC_DIR) $(AXI_VIP_DIR)/hdl_top/slave_agent_bfm/axi4_slave_monitor_bfm.sv >>& $(COMPILE_LOG) 
	
	$(VLOG) -work work $(INC_DIR) $(AXI_VIP_DIR)/hdl_top/axi4_interface/axi4_if.sv >>& $(COMPILE_LOG) 
	
	echo "------------------------------------------------------------"
	echo "Compiling CPU Packages"
	echo "------------------------------------------------------------"
	echo ""
	
	$(VLOG) -work work $(INC_DIR) ./cpu/cpu_sequence_item/cpu_sequence_item_packages.sv >>& $(COMPILE_LOG) 
	$(VLOG) -work work $(INC_DIR) ./cpu/cpu_active_agent/cpu_active_packages.sv >>& $(COMPILE_LOG) 
	$(VLOG) -work work $(INC_DIR) ./cpu/cpu_passive_agent/cpu_passive_packages.sv >>& $(COMPILE_LOG) 
	$(VLOG) -work work $(INC_DIR) ./cpu/cpu_packages.sv >>& $(COMPILE_LOG)
	
	echo "------------------------------------------------------------"
	echo "Compiling Environment"
	echo "------------------------------------------------------------"
	echo ""
	
	$(VLOG) -work work $(INC_DIR) ./env/axi_fifo_packages.sv >>& $(COMPILE_LOG) 	
	
	echo "------------------------------------------------------------"
	echo "Compiling Sequences"
	echo "------------------------------------------------------------"
	echo ""
	
	$(VLOG) -work work $(INC_DIR) ./sequence/axi_sequence/axi_sequence_packages.sv >>& $(COMPILE_LOG) 
	$(VLOG) -work work $(INC_DIR) ./sequence/cpu_sequence/cpu_sequence_packages.sv >>& $(COMPILE_LOG) 
	$(VLOG) -work work $(INC_DIR) ./virtual_sequence/axi_fifo_virtual_sequence_packages.sv >>& $(COMPILE_LOG)
	
	echo "------------------------------------------------------------"
	echo "Compiling Tests"
	echo "------------------------------------------------------------"
	echo ""
	
	$(VLOG) -work work $(INC_DIR) ./test/axi_fifo_test_packages.sv >>& $(COMPILE_LOG) 
	
	echo "------------------------------------------------------------"
	echo "Compiling Interface"
	echo "------------------------------------------------------------"
	echo ""
	
	$(VLOG) -work work $(INC_DIR) ./interface/fifo_interface.sv >>& $(COMPILE_LOG)  
	
	echo "------------------------------------------------------------"
	echo "Compiling Top"
	echo "------------------------------------------------------------"
	echo ""
	
	$(VLOG) -sv +acc +cover +fcover \
	-work work \
	-l top.log \
	$(INC_DIR) \
	./axi_fifo_top.sv  
	
#===============================================================================
# Simulation
#===============================================================================
sim:
	$(VSIM) \
	-c \
	-voptargs="+acc" \
	-assertdebug \
	-sva \
	-coverage \
	-l simulation.log \
	-do "log -r /*; coverage save -onexit -assert -directive -cvg -codeAll coverage.ucdb; run -all; exit" \
	-wlf waveform.wlf \
	-L work \
	+UVM_TESTNAME=axi_fifo_base_test \
	work.top
	
	vcover report -html coverage.ucdb -htmldir covReport -details

#===============================================================================
# Clean
#===============================================================================
clean:
	rm -rf \
	work \
	modelsim.ini \
	transcript \
	vsim.wlf \
	vsim_stacktrace.vstf \
	waveform.wlf \
	top.log \
	compile.log \
	simulation.log \
	coverage.ucdb \
	covReport

#===============================================================================
# Compile Report
#===============================================================================
compile_log_err:
	
	echo ""
	echo "================ Compilation Report ================"
	echo ""
	
	echo ""
	
	echo "Error Location:"
	grep -i "\*\* at" $(COMPILE_LOG) 
	
	if ($status != 0) then
			echo " No Error Location Found"
	endif
	
	echo ""
	
	echo "Summary:"
	grep -i "Errors:" $(COMPILE_LOG) 
	
	if ($status != 0) then
			echo ""
			echo "============ Compilation Successful ==============="
			echo ""
	endif
	
	echo ""
	
#===============================================================================
# Simulation Report
#===============================================================================
simulate_log_err:
	echo ""
	echo "================ Simulation Report ================"
	echo ""
	echo "UVM_FATAL:"
	grep FATAL simulation.log || echo "None"
	echo ""
	echo "UVM_ERROR:"
	grep ERROR simulation.log || echo "None"
	echo ""
	echo "UVM_WARNING:"
	grep WARNING simulation.log || echo "None"
	echo ""
	echo "Waveform : vsim -view waveform.wlf"
	echo "Coverage : covReport/index.html"

