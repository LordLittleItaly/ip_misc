# **********************
# Arguments Declarations
# **********************

TESTNAME?=NO_TEST

FILENAME?=./../top/ip_misc_fifo_async_top.v

COMPILE_FILELIST?=./comp_filelist/compile_filelist.list

TOP_NAME?=ip_misc_fifo_async_top

ifdef $(DO_FILE)
DO_CMD= -do $(DO_FILE)
else
DO_CMD= -do "run -all; quit -f"
endif

LINT?=0
WALL?=0

ifeq ($(WALL),1)
WALL_ARG=-Wall
else
WALL__ARG=
endif

# **********************
# Labels Declarations
# **********************

ifeq ($(LINT),1)
all : clean lint lib comp opt sim
else
all : clean lib comp opt sim
endif

comp_only : clean lib comp

# To Clean Redundant Files and Other Things
# --------------------------------------------
clean:
	@echo "Running Clean Command...";
	@rm -rf *.log *.vcd *.wlf;
	@rm -rf work questa.tops transcript;
	@rm -rf ./debug;
	@rm -rf ./obj_dir;

# Compilation
# --------------------------------------------
comp:
	@echo "Compiling the files...";
	@vlog \
	-64 \
	-work ./work \
	+acc \
	-l compile.log \
	-sv \
	-vopt \
	-writetoplevels questa.tops \
	$(FILENAME) \
	-f $(COMPILE_FILELIST);
	

# Simulation
# --------------------------------------------
sim:
	@echo "Starting Simulation...";
	@vsim \
	top_opt \
	-wlf vsim.wlf \
	$(DO_CMD) \
	-l $(TESTNAME).log \
	-64 \
	-c \
	+define+UVM_NO_DPI \
	+UVM_TESTNAME=$(TESTNAME);

# Library Generation
# --------------------------------------------
lib:
	@echo "Making Work Directory...";
	@vlib work;

# For the Optimization
# --------------------------------------------
opt:
	@echo "Running Optimization...";
	@vopt \
	+acc \
	$(TOP_NAME) \
	-o top_opt;

# Generate WLF from VCD
# --------------------------------------------
wave:
	@echo "Converting dump.vcd file to dump.wlf...";
	@echo "Removing all the redundant dumps...";
	@echo "Complete!";
	@vcd2wlf dump.vcd dump.wlf;
	@rm -rf dump.vcd;

# Move the Geberated Debug Logs
# --------------------------------------------
logs:
	@echo "Creating a new ./debug directory...";
	@mkdir ./debug;
	@mv *debug.log ./debug/;
	@echo "Moved all the logs successfully.";

# For the Qverilog Command
# --------------------------------------------
qv:
	qverilog \
	$(FILENAME);

qvc: clean qv

# Running a Lint using Verilator
# --------------------------------------------
lint:
	@echo "Linting the design..."
	@verilator \
	-f $(COMPILE_FILELIST) \
	$(FILENAME) \
	$(WALL_ARG) \
	--lint-only;
	@echo "Linting Complete!"
