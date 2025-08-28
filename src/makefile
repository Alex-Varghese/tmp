.IGNORE:

# -------------------------------
# Full flow with coverage (default)
# -------------------------------
all: clean new_funct compile clear simulate coverage_report

clean:
	rm -rf work/ transcript

new_funct:
	rm -f alu_funct_coverage.ucdb

compile:
	vlib work
	vmap work work
	vlog -sv +acc +cover +fcover -l alu.log top.sv

simulate:
	vsim -vopt work.top -voptargs=+acc=npr -assertdebug -l simulation.log -coverage -c -do \
	"coverage save -onexit -assert -directive -cvg -codeAll alu_coverage.ucdb; run -all; exit"

coverage_report:
	vcover report -html coverage.ucdb -htmldir covReport -details

read_cov:
	vcover report -details alu_funct_coverage.ucdb

clear:
	clear
	clear

main: clean
	vlib work
	vmap work work
	vlog -sv +acc +cover +fcover -l alu.log top.sv
	make clear
	vsim -vopt work.top -voptargs=+acc=npr -assertdebug -l simulation.log -coverage -c -do \
	"coverage save -onexit -assert -directive -cvg -codeAll coverage.ucdb; run -all; exit"
	vcover report -html coverage.ucdb -htmldir covReport -details


# -------------------------------
# Lightweight flow (no coverage)
# -------------------------------
clean_run:
	rm -rf work/

compile_run:
	vlib work
	vmap work work
	vlog alu_pkg.sv top.sv

run: compile_run
	vsim -c top -do "run -all; quit"
