echo "*** Set Technology library ***"

# Use 180nm library
set DB_LIB             "/mnt/f/WSL/lib/std/SCC018UG_UHD_RVT_V0.4a/liberty/1.8v"
set IO_LIB             "/mnt/f/WSL/lib/io/SP018WP_V1p1/syn/3p3v"
#set MEM_DB_LIB         "/eda/mmcomp"
set SYMBOL_LIB         "/mnt/f/WSL/lib/io/SP018WP_V1p1/syn/3p3v"
set DW_LIB             "/usr/synopsys/syn/L-2016.03-SP1/libraries/syn"

set search_path        "$search_path $DB_LIB $SYMBOL_LIB $DW_LIB $IO_LIB"
# set search_path        "$search_path $DB_LIB $SYMBOL_LIB $DW_LIB $MEM_DB_LIB"

# sc:standard cell; 011u:.11um; hd:high density; rvt:regular voltage threshold; ss:worst corner; v1p08:voltage1.08V; 125C:temperature 125; basic:basic library
set target_library     "scc018ug_uhd_rvt_ss_v1p62_125c_basic.db SP018WP_V1p1_max.db"
set link_library       "* $target_library"
# set symbol_library     "smic18.sdb"



set verilogout_show_unconnected_pins false
# set enable_recovery_removal_arcs true

# suppress_message [list VER-130 VER-129 VER-318 VER-936 ELAB-311]

# 开辟内存空间，用来存储中间的文件
define_design_lib WORK -path "temp_lib"


set_host_options -max_cores 8



#! set TOP_LEVEL top
set TOP_LEVEL top_pad
#! set clock and reset port name 
set clk clk_pad
set rstn rst_n_pad
set T 10
set unc_perc 0.02

#记录DC过程中对RTL做的修改，给后面形式验证等step提供
set_svf "./dc/read_rtl.svf"

echo "*** Reading Design ***"

#! analyze top
analyze -f sverilog -vcs +incdir+inc {
    ./rtl/top_pad.v
    ./rtl/adder_reg/conv.v
    ./rtl/conv_single_slide.v
    ./rtl/conv_slide.v
    ./rtl/adder_reg/conv_top.v
    ./rtl/conv_final.v
    ./rtl/top.v
    ./rtl/pool_top.sv
    ./rtl/pooling_channel.sv
    ./rtl/pooling_layer.sv
    ./rtl/storage_layer.sv
    ./rtl/compare_probabilities.sv
}

#构建层次关系
elaborate ${TOP_LEVEL} > rpt/elaborate.log

# current_design ${TOP_LEVEL}
current_design ${TOP_LEVEL}

#不使用其中的一些单元
set_dont_use [get_cells scc018ug_uhd_rvt_ss_v1p62_125c_basic/AO*]
set_dont_use [get_cells scc018ug_uhd_rvt_ss_v1p62_125c_basic/OA*]



#检查综合工程中是否缺少子模块
link

if {[link] == 0} {
    echo "Link Error"
    exit
}

#例化模块的名字修改
uniquify

#网表中可能存在assign语句，这会对布局布线产生影响,可能原因有：1.多个输出port连接在一个内部net上; 2.从输入port不经过任何逻辑直接到输出port上; 3.三态门引起的assign
#为了解决1和2，可以在综合前使用如下语句
set_fix_multiple_port_nets -all -buffer_constants

check_design > rpt/check_design_pre.log

#GTECH网表
write -f verilog -hier -output out/${TOP_LEVEL}_pre.v
write -f ddc -hier -output out/${TOP_LEVEL}_pre.ddc

echo "*** Constrainting Design ***"
#--------------------------- wire ---------------------------
#线性负载模型（找不到所以不用）
# set_wire_load_mode  top
# set_app_var auto_wire_load_selection true

#--------------------------- clock ---------------------------
set ideal_ports "$clk $rstn"
set timing_remove_clock_reconvergence_pessimism true
set_critical_range [expr $T * 0.1] $current_design 

#时钟约束
create_clock -name $clk [get_ports $clk] -period $T

#DC不会综合时钟树，时钟树综合由后端完成
set_dont_touch_network [get_clocks $clk]
set_ideal_network [get_clocks $clk]

#设置时钟电平转换的时间
# set_clock_transition 1.0 [get_clocks $clk]

#对rstn也是同理
set_dont_touch_network [get_ports  $rstn]
set_ideal_network [get_ports  $rstn]
# set_drive 0 [get_ports  $rstn]
#无时钟树的情况下，hold time没有意义，所以DC只分析setup time
#时钟到达各个寄存器的时间不同，被称为skew; 时钟在各个周期到达的时间不同，被称为jitter; 为后续设计留下一定时序余量，称为margin; skew jitter margin共同组成了uncertainty
# set_clock_uncertainty 0.9 [get_clocks $clk]
set_clock_uncertainty -setup [expr $T * $unc_perc] [get_clocks $clk]
set_clock_uncertainty -hold [expr $T * [expr $unc_perc * 0.5]] [get_clocks $clk]
#---------------------- input & output ----------------------


set_input_delay [expr 0.2*$T] -clock $clk [remove_from_collection [all_inputs] $ideal_ports] 
set_output_delay [expr 0.2*$T] -clock $clk [all_outputs]

##指定驱动input port信号的transition
set_input_transition 2.0 [remove_from_collection [all_inputs] $ideal_ports]

#指定输出port的load
set_load 5 [all_outputs]

  
# set_operating_conditions -max ss_v1p62_125c  -library scc018ug_uhd_rvt_ss_v1p62_125c_basic

#-------------------------- DRC ---------------------------
set_max_transition 3 [current_design]
set_max_fanout 100 [current_design]

#一般指定最大面积为0，以得到尽可能小的面积
set_max_area 0


echo "*** check and run ***"
check_design > rpt/check_design_post.log
check_timing

compile_ultra -gate_clock
# -no_autoungroup

set_svf "./dc/report.svf"

#网表中可能存在assign语句，这会对布局布线产生影响,可能原因有：1.多个输出port连接在一个内部net上; 2.从输入port不经过任何逻辑直接到输出port上; 3.三态门引起的assign
#为了解决3，可以在综合后，写网表前使用
set verilogout_no_tri ture

#DC综合出的网表命名不要出现特殊字符，符合Verilog风格
change_names -rules verilog -hierarchy

report_constraint -all_violator -verbose > rpt/con_violate.rpt
report_timing > rpt/timing.rpt
report_area -hierarchy > rpt/area.rpt
report_power > ./rpt/power.rpt


# 综合后，需要将结果进行保存，主要包括网表和约束, sdc(Synopsys Design Constrant)文件导出，因为sdc文件可以在很多第三方工具中使用，而DC的命令却不能
write_sdc -nosplit out/${TOP_LEVEL}.sdc

#保存综合后的网表文件与ddc
write -f ddc -hier -output out/${TOP_LEVEL}_mapped.ddc
write -f verilog -hier -output out/${TOP_LEVEL}_mapped.v

set_svf -off