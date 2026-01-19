################################################################################
# Synopsys ICC Script - DESKTOP PATHS & POWER FIX
# Location: /home/IC/Desktop/RESIC-V/pnr/scripts
################################################################################

# 1. DEFINING PATHS (Based on your new Desktop structure)
# ------------------------------------------------------------------------------
set DESIGN_ROOT   "/home/IC/Desktop/RESIC-V"
set PNR_PATH      "$DESIGN_ROOT/pnr"
set SYN_OUTPUT    "$DESIGN_ROOT/syn/output"

# Folders inside pnr directory (based on your image)
set RUNTIME_PATH  "$PNR_PATH/runtime"
set OUTPUTS_PATH  "$PNR_PATH/output"
set REPORTS_PATH  "$PNR_PATH/reports"

# Clean Start
file mkdir $OUTPUTS_PATH $REPORTS_PATH
remove_design -all

# 2. LIBRARIES & INPUTS
# ------------------------------------------------------------------------------
# Assuming netlist is still in syn/output. If you moved it to pnr/inputs, change this line.
set NETLIST_FILE  "$SYN_OUTPUT/pipeline_netlist.v"
set SDC_FILE      "$SYN_OUTPUT/pipeline.sdc"

# Update: std_cells is now inside the pnr folder based on your screenshot
set SEARCH_PATH   "$PNR_PATH/std_cells"
set TARGET_LIB    "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db"
set MW_DESIGN_LIB "$RUNTIME_PATH/Pipeline_Lib" 

# TLU+ Files (Adjust path if they are deep inside std_cells)
set TLUPLUS_MAX   "$SEARCH_PATH/tluplus/cl013g_1p2v_cmax.tluplus"
set TLUPLUS_MIN   "$SEARCH_PATH/tluplus/cl013g_1p2v_cmin.tluplus"
set TLUPLUS_MAP   "$SEARCH_PATH/tluplus/star.map_130"

set search_path [list . $SEARCH_PATH]
set target_library $TARGET_LIB
set link_library   [list "*" $TARGET_LIB]

# 3. IMPORT DESIGN
# ------------------------------------------------------------------------------
puts "Opening Library..."
# If library exists, open it. If not, creating it might be needed (assuming it exists from previous steps)
if {[file exists $MW_DESIGN_LIB]} {
    open_mw_lib $MW_DESIGN_LIB
} else {
    create_mw_lib $MW_DESIGN_LIB -technology "$SEARCH_PATH/tech_file.tf" -mw_reference_library "$SEARCH_PATH/tsmc13_mw_lib"
    open_mw_lib $MW_DESIGN_LIB
}

import_designs $NETLIST_FILE -format verilog -top Pipeline_top
if {[file exists $TLUPLUS_MAX]} {
    set_tlu_plus_files -max_tluplus $TLUPLUS_MAX -min_tluplus $TLUPLUS_MIN -tech2itf_map $TLUPLUS_MAP
}
read_sdc $SDC_FILE

# 4. FLOORPLAN
# ------------------------------------------------------------------------------
puts "Starting Floorplan..."

create_net -power VDD
create_net -ground VSS

# Creating Core (Auto-Rows)
create_floorplan -control_type aspect_ratio \
                 -core_utilization 0.6 \
                 -core_aspect_ratio 1.0 \
                 -left_io2core 40 \
                 -bottom_io2core 40 \
                 -right_io2core 40 \
                 -top_io2core 40

# --- [CRITICAL FIX] CONNECT POWER PINS ---
# This ensures cells are "alive" and valid for placement
puts "Connecting Standard Cell Pins..."
derive_pg_connection -power_net VDD -ground_net VSS -power_pin VDD -ground_pin VSS
derive_pg_connection -power_net VDD -ground_net VSS -tie

# Note: Skipping Rings temporarily to ensure placement works first.

save_mw_cel -as floorplan_done

# 5. PLACEMENT
# ------------------------------------------------------------------------------
puts "Starting Placement..."
place_opt
save_mw_cel -as placement_done

# 6. CTS & ROUTE (Basic)
# ------------------------------------------------------------------------------
puts "Starting CTS & Route..."
clock_opt -only_cts -no_clock_route
save_mw_cel -as cts_done
route_opt
save_mw_cel -as routing_done

# 7. OUTPUTS
# ------------------------------------------------------------------------------
puts "Generating Outputs..."
write_stream -format gds -cells Pipeline_top $OUTPUTS_PATH/pipeline_chip.gds
write_verilog $OUTPUTS_PATH/pipeline_pr.v

puts "SUCCESS: Check GUI now! Cells should be placed."
start_gui
