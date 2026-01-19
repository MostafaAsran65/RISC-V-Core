################################################################################
# Synopsys Design Compiler Synthesis Script
# Project: RISC-V Pipeline
# Version: DC 2018 Compatible
################################################################################
#first go to correct directio cd /home/ICer/Desktop/RESIC-V/syn/scripts
#1. SETUP PATHS & DIRECTORIES
################################################################################

# ------------------------------------------------------------------------------
# RELATIVE PATHS CONFIGURATION
# ------------------------------------------------------------------------------
# Assuming script execution from: <PROJECT_ROOT>/syn/scripts/
# RTL is located at: <PROJECT_ROOT>/syn/rtl/ (Based on your previous path)
# Libs are located at: <PROJECT_ROOT>/syn/std_cells/

# Go up one level (..) to exit 'scripts' folder, then into target folder
set RTL_PATH    "../rtl"
set LIB_PATH    "../std_cells"

# Output directories (Relative to the scripts folder)
set REPORTS_PATH "../reports"
set OUTPUTS_PATH "../output"
set RUNTIME_PATH "../runtime" 

# Create directories if they do not exist
file mkdir $REPORTS_PATH
file mkdir $OUTPUTS_PATH
file mkdir $RUNTIME_PATH

# ------------------------------------------------------------------------------
# LIBRARY SETUP
# ------------------------------------------------------------------------------
# Redirect WORK library to 'runtime' to keep cleanliness
define_design_lib WORK -path "$RUNTIME_PATH"

# Search Path Setup
set search_path [list . $RTL_PATH $LIB_PATH]

# Target Technology Library
set target_library "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db"
set link_library   [list "*" $target_library] 

################################################################################
# 2. SVF SETUP
################################################################################
set_svf "$RUNTIME_PATH/default.svf"

################################################################################
# 3. READ & ANALYZE RTL
################################################################################

remove_design -all

# List of Verilog source files (Using Relative Path variable)
set my_verilog_files [list \
    "$RTL_PATH/Mux.v" \
    "$RTL_PATH/PC.v" \
    "$RTL_PATH/PC_Adder.v" \
    "$RTL_PATH/Sign_Extend.v" \
    "$RTL_PATH/ALU.v" \
    "$RTL_PATH/Register_File.v" \
    "$RTL_PATH/Instruction_Memory.v" \
    "$RTL_PATH/Data_Memory.v" \
    "$RTL_PATH/Main_Decoder.v" \
    "$RTL_PATH/ALU_Decoder.v" \
    "$RTL_PATH/Control_Unit_Top.v" \
    "$RTL_PATH/Hazard_unit.v" \
    "$RTL_PATH/Fetch_Cycle.v" \
    "$RTL_PATH/Decode_Cyle.v" \
    "$RTL_PATH/Execute_Cycle.v" \
    "$RTL_PATH/Memory_Cycle.v" \
    "$RTL_PATH/Writeback_Cycle.v" \
    "$RTL_PATH/Pipeline_Top.v" \
]

puts "Analyzing RTL files..."
analyze -format verilog $my_verilog_files

elaborate Pipeline_top

current_design Pipeline_top
link

################################################################################
# 4. LINTING
################################################################################
puts "Running LINT..."
check_design > $REPORTS_PATH/lint.rpt

################################################################################
# 5. CONSTRAINTS
################################################################################

create_clock -name "clk" -period 10 -waveform {0 5} [get_ports clk]
set_ideal_network [get_ports rst]

set_input_delay -max 2.0 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay -max 2.0 -clock clk [all_outputs]
set_load 0.05 [all_outputs]

check_timing > $REPORTS_PATH/check_timing_pre_compile.rpt

################################################################################
# 6. COMPILE
################################################################################
puts "Starting Compilation..."

# Optimization settings
set verilogout_no_tri true
set verilogout_show_unconnected_pins true

# Compile Command (Standard for 130nm)
compile -map_effort medium

################################################################################
# 7. STA & REPORTS
################################################################################
puts "Generating Reports..."

report_timing -path full -delay max -max_paths 20 -nworst 1 > $REPORTS_PATH/sta_setup.rpt
report_timing -path full -delay min -max_paths 20 -nworst 1 > $REPORTS_PATH/sta_hold.rpt
report_constraint -all_violators > $REPORTS_PATH/sta_violations.rpt
report_area > $REPORTS_PATH/area.rpt
report_power > $REPORTS_PATH/power.rpt

################################################################################
# 8. OUTPUTS
################################################################################
puts "Saving Outputs..."

write -format verilog -hierarchy -output $OUTPUTS_PATH/pipeline_netlist.v
write -format ddc -hierarchy -output $OUTPUTS_PATH/pipeline.ddc
write_sdc $OUTPUTS_PATH/pipeline.sdc
write_sdf $OUTPUTS_PATH/pipeline.sdf

puts "Synthesis Completed Successfully!"
puts "Starting GUI..."
gui_start
