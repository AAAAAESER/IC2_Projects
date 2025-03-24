echo "*** Set Technology library ***"

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



set verilogout_show_unconnected_pins
# set enable_recovery_removal_arcs true

# suppress_message [list VER-130 VER-129 VER-318 VER-936 ELAB-311]

# 开辟内存空间，用来存储中间的文件
define_design_lib WORK -path "temp_lib"




echo "*** Reading Design ***"
#记录DC过程中对RTL做的修改，给后面形式验证等step提供
set_svf "./dc/read_rtl.svf"

#! set TOP_LEVEL top
set TOP_LEVEL FC_by_cov_4_4

#! set clock and reset port name 
set clk clk
set rstn rst_n

#! analyze top
analyze -f sverilog -vcs +incdir+inc {
    ./rtl/FC_by_cov_4_4.sv
    ./rtl/FC_by_cov_1_1.sv
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

echo "*** Constrainting Design ***"
#--------------------------- wire ---------------------------
#线性负载模型
# set_wire_load_mode  top
# set_app_var auto_wire_load_selection true

#--------------------------- clock ---------------------------
create_clock -name $clk -period 20 [get_ports $clk]

#DC不会综合时钟树，时钟树综合由后端完成
set_dont_touch_network [get_clocks $clk]
set_ideal_network [get_clocks $clk]
set_drive 0 [get_clocks $clk]

#设置时钟电平转换的时间
set_clock_transition -max 0.1 [get_clocks $clk]

#无时钟树的情况下，hold time没有意义，所以DC只分析setup time
#时钟到达各个寄存器的时间不同，被称为skew; 时钟在各个周期到达的时间不同，被称为jitter; 为后续设计留下一定时序余量，称为margin; skew jitter margin共同组成了uncertainty
set_clock_uncertainty -setup 0.1 [get_clocks $clk]

#源到时钟port的延迟
set_clock_latency -source -max 0 [get_clocks $clk]
#时钟port到内部cell的延迟
set_clock_latency -max 0.1 [get_clocks $clk]

#如果对时钟进行了分频，需要指定分频后的时钟;将FF1的输出Q作为分频后的时钟,分频系数是4,分频时钟不会继承原时钟的约束，需要额外约束分频时钟
#creat_generated_clock -divied_by 4 -name $clk_DIV -source [get_ports $clk] [get_pins FF1/Q]



#create_clock -name $clk_MNoC -period 10 [get_ports $clk_MNoC]
#
#set_dont_touch_network [get_clocks $clk_MNoC]
#set_ideal_network [get_clocks $clk_MNoC]
#set_drive 0 [get_clocks $clk_MNoC]
#
#set_clock_transition -max 0.1 [get_clocks $clk_MNoC]
#set_clock_uncertainty -setup 0.1 [get_clocks $clk_MNoC]
#set_clock_latency -source -max 0 [get_clocks $clk_MNoC]
#set_clock_latency -max 0.1 [get_clocks $clk_MNoC]
#
##如果设计内存在异步时钟，其异步接口应该在设计时保证功能正确,所以综合时不需要约束异步接口,这时可以将异步路径false掉，让DC不分析异步时钟之间的路径
#set_false_path -from [get_clocks $clk_test] -to [get_clocks $clk_MNoC]
#set_false_path -from [get_clocks $clk_MNoC] -to [get_clocks $clk_test]
##更加便捷的方式是，直接将它们指定为异步时钟
#set_clock_groups -asynchronous -group $clk_test -group $clk_MNoC

#---------------------- input & output ----------------------
#输入输出port延迟约束
#set_input_delay -max 60 -clock $clk [remove_from_collection [all_inputs][get_ports $clk]]
set_input_delay -max 0 -clock $clk [remove_from_collection [all_inputs] [get_ports $clk]]
#set_input_delay -max 100 -clock $clk [get_ports i_pc]
#set_input_delay -max 100 -clock $clk [get_ports i_rs1idx]
#set_input_delay -max 100 -clock $clk [get_ports i_rs2idx]
#set_output_delay -max 50 -clock $clk [get_ports disp_o_alu_rs1]
#set_output_delay -max 50 -clock $clk [get_ports disp_o_alu_rs2]
#set_output_delay -max 50 -clock $clk [get_ports disp_o_alu_rdwen]
#set_output_delay -max 50 -clock $clk [get_ports disp_o_alu_rdidx]
#set_output_delay -max 50 -clock $clk [get_ports disp_o_alu_info]
#set_output_delay -max 50 -clock $clk [get_ports disp_o_alu_pc]
#set_output_delay -max 6  -clock $clk [get_ports sp_out]
set_output_delay -max 0 -clock $clk [all_outputs]
remove_input_delay [get_ports $clk]

set_dont_touch_network [get_ports  $rstn]
set_ideal_network [get_ports  $rstn]
set_drive 0 [get_ports  $rstn]
#
##指定驱动input port信号的transition
#set_input_transition 0.1 {TestBoot}

#指定输出port的load
set_load 0.05 [all_outputs]

#如果design中有需要执行多个cycle的组合逻辑,可以设置multiple cycle path来约束
#指定path执行的周期是6,工具会在第6个时钟上升沿检查setup time，在第5个周期上升沿检查hold time
#set_multicycle_path -setup 6 -from {A_reg[*] B_reg[*]} -to C_reg[*]
#为了将hold time检查移至第0个周期上升沿，需要使用：
#set_multicycle_path -hold 5 -from {A_reg[*] B_reg[*]} -to C_reg[*]

#-------------------------- DRC ---------------------------
#set_max_transition 0.2 [current_design]
#set_max_fanout 200 [current_design]

#一般指定最大面积为0，以得到尽可能小的面积
set_max_area 0


echo "*** check and run ***"
check_design
check_timing

set_host_options -max_cores 4
compile_ultra 
#-no_autoungroup

set_svf "./dc/report.svf"

#网表中可能存在assign语句，这会对布局布线产生影响,可能原因有：1.多个输出port连接在一个内部net上; 2.从输入port不经过任何逻辑直接到输出port上; 3.三态门引起的assign
#为了解决3，可以在综合后，写网表前使用
set verilogout_no_tri ture

#DC综合出的网表命名不要出现特殊字符，符合Verilog风格
change_names -rules verilog -hierarchy

report_constraint -all_violator -verbose > rpt/con_violate.rpt
report_timing > rpt/timing.rpt
report_area -hierarchy > rpt/area.rpt

# 综合后，需要将结果进行保存，主要包括网表和约束, sdc(Synopsys Design Constrant)文件导出，因为sdc文件可以在很多第三方工具中使用，而DC的命令却不能
write_sdc > out/${TOP_LEVEL}.sdc

#保存综合后的网表文件与ddc
write -f ddc -hier -output out/${TOP_LEVEL}_mapped.ddc
write -f verilog -hier -output out/${TOP_LEVEL}_mapped.v
