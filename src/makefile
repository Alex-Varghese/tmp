## Makefile for SystemVerilog Simulation (Silent Version)
##
## --- Variables ---
#FILE ?= top.sv

## --- Auto-Detection Logic ---
#ifeq ($(TOP),)
#  TOP := top
#endif

## --- Sanity Check ---
#ifeq ($(TOP),)
#  $(error Could not automatically find a 'module' definition in $(FILE). Please specify it manually with TOP=<module_name>)
#endif

## --- Targets ---
#all: simulate

## The '@' symbol already prevents the command itself from being printed.
## We have removed the extra "@echo" lines for a cleaner output.
#compile:
#	@vlog -sv $(FILE)

##@vsim -c $(TOP) +UVM_VERBOSITY=UVM_HIGH -do "run -all ; quit"
#simulate: compile
#	@vsim -c $(TOP) +UVM_VERBOSITY=UVM_HIGH -do "run -all ; quit"

#clean:
#	@rm -rf transcript vsim.wlf work *.log

#.PHONY: all compile simulate clean

### ----------------------------------------------------------------------
# Makefile for SystemVerilog Simulation

# --- Variables ---
FILE ?= top.sv
TOP ?= top

# --- Simulation Options ---
# This section sets the simulation flags based on the VERBOSITY variable.
VERBOSITY ?= NORMAL
VSIM_EXTRA_OPTS =

ifeq ($(VERBOSITY), HIGH)
	VSIM_EXTRA_OPTS = +UVM_VERBOSITY=UVM_HIGH
endif
ifeq ($(VERBOSITY), DEBUG)
	VSIM_EXTRA_OPTS = +UVM_VERBOSITY=UVM_DEBUG
endif


# --- Targets ---
.PHONY: all compile simulate clean h d

# Default target runs a normal simulation
all: simulate

# --- Shortcut Targets ---
# make   - executes normally (VERBOSITY is set to default)
# make h - executes with VERBOSITY=HIGH
# make d - executes with VERBOSITY=DEBUG
h:
	@$(MAKE) --no-print-directory simulate VERBOSITY=HIGH

d:
	@$(MAKE) --no-print-directory simulate VERBOSITY=DEBUG
# --- End of Shortcut Targets ---


compile:
	@vlog -sv $(FILE)

simulate: compile
	@echo "--- Running Simulation (Verbosity: $(VERBOSITY)) ---"
	@vsim -c $(TOP) $(VSIM_EXTRA_OPTS) -do "run -all ; quit"

clean:
	@rm -rf transcript vsim.wlf work *.log
# 	#################
###############################################
# # QUESTA := /home/share/questa.csh
# # SHELL := /bin/csh

# IGNORE:
# 	make clean
# 	make view

# .ONESHELL:

# all:
# 	source $(QUESTA)
# 	make clean
# 	make compile
# 	make simulate

# main:
# 	# source $(QUESTA)
# 	make clean
# 	vlog -sv +acc +cover +fcover -l alu_top.log top.sv
# 	vsim -vopt work.top -voptargs=+acc=npr -assertdebug -l simulation.log -coverage -c -do "coverage save -onexit -assert -directive -cvg -codeAll coverage.ucdb; run -all; exit"
# 	vcover report -html coverage.ucdb -htmldir covReport -details

# read:
# 	vcover report -details coverage.ucdb

# view:
# 	firefox ./covReport/index.html

# compile:
# 	vlog -sv alu_top.sv

# simulate:
# 	vsim -c top +UVM_VERBOSITY=UVM_MEDIUM -do "run -all;exit"

# clean:
# 	rm -rf transcript work/
# 	clear
# 	clear
