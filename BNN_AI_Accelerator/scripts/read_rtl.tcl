#记录DC过程中对RTL做的修改，给后面形式验证等step提供
set_svf "read_rtl.svf"

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
current_design CNN_top
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
