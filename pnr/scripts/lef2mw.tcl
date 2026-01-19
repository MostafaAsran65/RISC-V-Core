################################################################################
# Milkyway Script: Convert LEF to Milkyway Library
# Run command: mw_shell -f lef2mw.tcl
################################################################################

# 1. SETUP PATHS
################################################################################
set PNR_WORK_PATH "../runtime"
set LEF_PATH      "../lef"
set MW_LIB_NAME   "$PNR_WORK_PATH/Pipeline_Lib"

# Define LEF Files (Using 6-Layer Metal Tech File based on your uploads)
set LEF_TECH_FILE "$LEF_PATH/tsmc13fsg_6lm_tech.lef"
set LEF_CELL_FILE "$LEF_PATH/tsmc13_m_macros.lef"

# Create output directory
file mkdir $PNR_WORK_PATH

################################################################################
# 2. CREATE LIBRARY
################################################################################

puts "----------------------------------------------------------------"
puts "Creating Milkyway Library from LEF..."
puts "----------------------------------------------------------------"

# Delete previous library to avoid conflicts
if {[file exists $MW_LIB_NAME]} {
    file delete -force $MW_LIB_NAME
}

# Create Library and Read LEF files
# This creates the physical database needed for ICC
read_lef -lib_name $MW_LIB_NAME \
         -tech_lef_files $LEF_TECH_FILE \
         -cell_lef_files $LEF_CELL_FILE

# Verify library creation
set lib_opened [list_lib]
puts "Libraries currently open: $lib_opened"

puts "----------------------------------------------------------------"
puts "Milkyway Library Created Successfully at: $MW_LIB_NAME"
puts "----------------------------------------------------------------"

exit