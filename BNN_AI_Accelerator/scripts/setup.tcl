# logic_library
#               --> link_library(工艺库) 
#                                        --> target_library(标准单元库) --> base (base cell)      --> HVT/RVT/LVT/SLVT --> NLDMs/CCS
#                                                                      --> PMK  (low power cell) --> HVT/RVT/LVT/SLVT --> NLDMs/CCS
#                                                                      --> ECO                   --> HVT/RVT/LVT/SLVT --> NLDMs/CCS
#                                        --> others : memory/IO/PHY/hardcore
#               --> generic_library    
#                                        --> symbol_library
#                                        --> synthetic_library : standard.sldb(HDL运算符) dw_foundation.sldb(DW库)

echo "*** Set Technology library ***"

# # Use 110nm library
# set DB_LIB             "/eda/lib/SCC011UMS_UHD_RVT_V1p0/liberty/1.2v"
# set MEM_DB_LIB         "/eda/mmcomp"
# set SYMBOL_LIB         "/eda/lib/SCC011UMS_UHD_RVT_V1p0/symbol"
# set DW_LIB             "/eda/dc/libraries/syn"

# set search_path        "$search_path $DB_LIB $SYMBOL_LIB $DW_LIB $MEM_DB_LIB"

# # sc:standard cell; 011u:.11um; hd:high density; rvt:regular voltage threshold; ss:worst corner; v1p08:voltage1.08V; 125C:temperature 125; basic:basic library
# set target_library     "scc011ums_uhd_rvt_ss_v1p08_125c_basic.db"
# set link_library       "* scc011ums_uhd_rvt_ss_v1p08_125c_basic.db standard.sldb dw_foundation.sldb gtech.db"
# set symbol_library     "scc011ums_uhd_rvt.sdb"
# set synthetic_library  "standard.sldb dw_foundation.sldb"


# # Use 55nm library
# set DB_LIB             "/mnt/f/WSL/SMIC_55/SCC55NLL_HS_RVT_V2p1a/std_db"
# #set MEM_DB_LIB         "/eda/mmcomp"
# set SYMBOL_LIB         "/mnt/f/WSL/SMIC_55/SCC55NLL_HS_RVT_V2p1a/symbol"
# set DW_LIB             "/usr/synopsys/syn/L-2016.03-SP1/libraries/syn"

# set search_path        "$search_path $DB_LIB $SYMBOL_LIB $DW_LIB"
# # set search_path        "$search_path $DB_LIB $SYMBOL_LIB $DW_LIB $MEM_DB_LIB"

# # sc:standard cell; 011u:.11um; hd:high density; rvt:regular voltage threshold; ss:worst corner; v1p08:voltage1.08V; 125C:temperature 125; basic:basic library
# set target_library     "scc55nll_hs_rvt_ss_v1p08_125c_basic.db"
# set link_library       "* scc55nll_hs_rvt_ss_v1p08_125c_basic.db"
# set symbol_library     "scc55nll_hs_rvt.sdb"
# #set synthetic_library  "standard.sldb dw_foundation.sldb"

# Use 180nm library
set DB_LIB             "/mnt/f/WSL/smic180/digital/sc/synopsys"
#set MEM_DB_LIB         "/eda/mmcomp"
set SYMBOL_LIB         "/mnt/f/WSL/smic180/digital/sc/symbols/synopsys"
set DW_LIB             "/usr/synopsys/syn/L-2016.03-SP1/libraries/syn"

set search_path        "$search_path $DB_LIB $SYMBOL_LIB $DW_LIB"
# set search_path        "$search_path $DB_LIB $SYMBOL_LIB $DW_LIB $MEM_DB_LIB"

# sc:standard cell; 011u:.11um; hd:high density; rvt:regular voltage threshold; ss:worst corner; v1p08:voltage1.08V; 125C:temperature 125; basic:basic library
set target_library     "typical.db"
set link_library       "* typical.db"
set symbol_library     "smic18.sdb"
#set synthetic_library  "standard.sldb dw_foundation.sldb"


# set verilogout_show_unconnected_pins
# set enable_recovery_removal_arcs true

# suppress_message [list VER-130 VER-129 VER-318 VER-936 ELAB-311]

# 开辟内存空间，用来存储中间的文件
define_design_lib WORK -path "temp_lib"


echo "*** Reading Design ***"

set file_name CNN_top

#记录DC过程中对RTL做的修改，给后面形式验证等step提供
set_svf "./dc/read_rtl.svf"

#! set TOP_LEVEL top
set TOP_LEVEL CNN_top

#! set clock and reset port name 
set clk clk
set rstn rstn

#! analyze top
analyze -f verilog -vcs +incdir+inc {
    CNN_top.v
    conv.v
    conv_mix_6.v
    fc_12.v
    maxpool.v
    window.v
}

#构建层次关系
elaborate ${TOP_LEVEL} > rpt/elaborate.log

# current_design ${TOP_LEVEL}
current_design ${TOP_LEVEL}
#检查综合工程中是否缺少子模块
# link

# if {[link] == 0} {
#     #echo "Link Error"
#     exit
# }

#例化模块的名字修改
uniquify

#网表中可能存在assign语句，这会对布局布线产生影响,可能原因有：1.多个输出port连接在一个内部net上; 2.从输入port不经过任何逻辑直接到输出port上; 3.三态门引起的assign
#为了解决1和2，可以在综合前使用如下语句
set_fix_multiple_port_nets -all -buffer_constants

check_design > rpt/check_design.log

#GTECH网表
write -f verilog -hier -output out/${TOP_LEVEL}_pre.v
write -f ddc -hier -output out/${TOP_LEVEL}_pre.ddc
