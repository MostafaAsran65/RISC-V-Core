################################################################################
# ICC2 Library Creation (The Bypass Method)
################################################################################
set WORK_PATH     "../runtime"
set OUTPUT_PATH   "../output"
set LEF_DIR       "../lef"
set STD_CELLS_DIR "../std_cells"

file mkdir $WORK_PATH
file mkdir $OUTPUT_PATH

set search_path [list . $LEF_DIR $STD_CELLS_DIR]
set NDM_LIB_NAME "tsmc13_std.ndm"

# استخدام الملفات النظيفة البسيطة
set TECH_LEF     "simple_tech.lef"
set MACRO_LEF    "simple_macros.lef"
set DB_FILE      "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db"

# تنظيف القديم
file delete -force $NDM_LIB_NAME
file delete -force "$OUTPUT_PATH/$NDM_LIB_NAME"

puts "Step 1: Creating Empty Physical Workspace..."
# لاحظ: شيلنا -technology خالص عشان نتفادى الإيرور
create_workspace $NDM_LIB_NAME -flow physical_only

puts "Step 2: Reading Technology LEF..."
# قراءة ملف التكنولوجي كـ LEF عادي
read_lef $TECH_LEF

puts "Step 3: Reading Macros LEF..."
# قراءة ملف الخلايا
read_lef $MACRO_LEF

puts "Step 4: Reading DB..."
if {[file exists [which $DB_FILE]]} {
    read_db $DB_FILE
} else {
    puts "Warning: DB File not found."
}

puts "Step 5: Checking & Saving..."
check_workspace
write_workspace -format ndm -output "$OUTPUT_PATH/$NDM_LIB_NAME"

puts "SUCCESS: Library created at $OUTPUT_PATH/$NDM_LIB_NAME"
exit
