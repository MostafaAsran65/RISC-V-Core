################################################################################
# Synopsys Formality Verification Script
# Project: RISC-V Pipeline
# Description: Professional setup with error suppression for Memory Models.
################################################################################

# 1. CLEAN START & WORKSPACE SETUP
################################################################################

# Clear previous session
remove_container -all

# --- CRITICAL FIX for FMR_ELAB-147 Error ---
# Suppress "Index may take values outside array bound" warning.
# This tells Formality to ignore that our 32-bit address is larger than the 1024 memory size.
suppress_message FMR_ELAB-147

# Define local directories
set FM_RUNTIME_PATH "../runtime"
set FM_REPORTS_PATH "../reports"

# Create directories if missing
file mkdir $FM_RUNTIME_PATH
file mkdir $FM_REPORTS_PATH

# Redirect Log
set sh_output_log_file "$FM_RUNTIME_PATH/formality.log"

################################################################################
# 2. DEFINE INPUT PATHS
################################################################################

set SYN_BASE_PATH "/home/IC/RESIC-V/syn"

set RTL_PATH      "$SYN_BASE_PATH/rtl"
set NETLIST_PATH  "$SYN_BASE_PATH/output"
set LIB_PATH      "$SYN_BASE_PATH/std_cells"
set SVF_PATH      "$SYN_BASE_PATH/runtime" 

set LIB_NAME "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db"
set TOP_MODULE "Pipeline_top"

################################################################################
# 3. LOAD GUIDANCE (SVF)
################################################################################
puts "----------------------------------------------------------------"
puts "Step 1: Loading SVF Guidance..."
puts "----------------------------------------------------------------"

set_svf "$SVF_PATH/default.svf"

################################################################################
# 4. READ LIBRARIES & NETLIST (Implementation)
################################################################################
puts "----------------------------------------------------------------"
puts "Step 2: Reading Implementation (Netlist)..."
puts "----------------------------------------------------------------"

read_db "$LIB_PATH/$LIB_NAME"
read_verilog -container i -netlist "$NETLIST_PATH/pipeline_netlist.v"
set_top i:/WORK/$TOP_MODULE

################################################################################
# 5. READ RTL (Reference)
################################################################################
puts "----------------------------------------------------------------"
puts "Step 3: Reading Reference (RTL)..."
puts "----------------------------------------------------------------"

set rtl_files [list \
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

read_verilog -container r -libname WORK -05 $rtl_files
set_top r:/WORK/$TOP_MODULE

################################################################################
# 6. MATCH & VERIFY
################################################################################
puts "----------------------------------------------------------------"
puts "Step 4: Matching & Verifying..."
puts "----------------------------------------------------------------"

match

if { [verify] } {
    puts "################################################################"
    puts "  SUCCESS: Verification SUCCEEDED! RTL matches Netlist."
    puts "################################################################"
} else {
    puts "################################################################"
    puts "  ERROR: Verification FAILED! Differences detected."
    puts "  Check report: $FM_REPORTS_PATH/failing_points.rpt"
    puts "################################################################"
    report_failing_points > "$FM_REPORTS_PATH/failing_points.rpt"
}

################################################################################
# 7. LAUNCH GUI
################################################################################
puts "Starting Formality GUI..."
start_gui