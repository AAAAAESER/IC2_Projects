set_svf "report.svf"

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
