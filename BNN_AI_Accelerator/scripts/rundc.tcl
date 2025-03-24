source -echo -v  setup.tcl

echo "*** Reading Design ***"
source -echo -v read_rtl.tcl > rpt/read_rtl.log

echo "*** Constrainting Design ***"
source -echo -v constrains.tcl > rpt/constrains.log

check_design
check_timing

set_host_options -max_cores 4
compile_ultra -no_autoungroup

source report.tcl
