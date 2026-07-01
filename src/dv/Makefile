QUESTA := /home/share/questa.csh
SHELL := /bin/csh
FILE := axi_fifo_top

.ONESHELL:
	
.SILENT:
	make main

.IGNORE: 
	main

all:
	make main

main:
	source $(QUESTA)
	make clean
	vlog -sv +acc +cover +fcover -l top.log $(FILE).sv
	make compile_log_err
	vsim -vopt work.top -voptargs=+acc=npr -assertdebug -l simulation.log -sva -coverage -c \
		-do "log -r /*; add wave -r /*; coverage save -onexit -assert -directive -cvg -codeAll coverage.ucdb; run -all; exit" \
		-wlf waveform.wlf
	make simulate_log_err
	vcover report -html coverage.ucdb -htmldir covReport -details

read:
	source $(QUESTA)
	vcover report -details coverage.ucdb

view:
	firefox ./covReport/index.html

log:
	less -R simulation.log

compile:
	vlog -sv $(FILE).sv

simulate:
	vsim -c top +UVM_VERBOSITY=UVM_MEDIUM -do "run -all;exit"

clean:
	rm -rf transcript work covReport
	rm -f simulation.log wave.vcd top.log coverage.ucdb waveform.wlf
	clear
	clear

compile_log_err:
	echo ""
	echo "-----------------------------------------------------------------"
	echo "------------------- Compilation Report --------------------------"
	echo ""
	echo " Detailed Errors:"
	grep -i "\*\* at" top.log || echo "No Errors found"
	echo ""
	echo " Summary:"
	grep -i "^Errors:" top.log || echo "Summary not found"
	echo ""
	echo "Log file path: top.log"
	echo ""
	echo "-----------------------------------------------------------------"
	echo "-----------------------------------------------------------------"
	echo ""

simulate_log_err:
	echo ""
	echo "------------------------------------------------------------"
	echo "-------------------- Simulation Report ---------------------"
	echo ""
	echo "UVM Fatal"
	grep "FATAL" simulation.log || echo "No UVM_FATAL"
	echo ""
	echo "UVM Errors"
	grep "ERROR" simulation.log || echo "No UVM_ERROR"
	echo ""
	echo "UVM Warnings"
	grep "WARNING" simulation.log || echo "No UVM_WARNING"
	echo ""
	echo "Waveform: vsim -view waveform.wlf &"
	echo "------------------------------------------------------------"
	echo ""

