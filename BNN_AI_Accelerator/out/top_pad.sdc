###################################################################

# Created by write_sdc on Fri Dec 27 19:28:49 2024

###################################################################
set sdc_version 2.0

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_max_fanout 100 [current_design]
set_max_transition 3 [current_design]
set_max_area 0
set_load -pin_load 5 [get_ports {data_out_pad[1]}]
set_load -pin_load 5 [get_ports {data_out_pad[0]}]
set_load -pin_load 5 [get_ports in_ready_pad]
set_load -pin_load 5 [get_ports out_en_pad]
set_ideal_network [get_ports clk_pad]
set_ideal_network [get_ports rst_n_pad]
create_clock [get_ports clk_pad]  -period 5.3  -waveform {0 2.65}
set_clock_uncertainty -setup 0.106  [get_clocks clk_pad]
set_clock_uncertainty -hold 0.053  [get_clocks clk_pad]
set_input_delay -clock clk_pad  1.06  [get_ports mode_pad]
set_input_delay -clock clk_pad  1.06  [get_ports {data_in_pad[15]}]
set_input_delay -clock clk_pad  1.06  [get_ports {data_in_pad[14]}]
set_input_delay -clock clk_pad  1.06  [get_ports {data_in_pad[13]}]
set_input_delay -clock clk_pad  1.06  [get_ports {data_in_pad[12]}]
set_input_delay -clock clk_pad  1.06  [get_ports {data_in_pad[11]}]
set_input_delay -clock clk_pad  1.06  [get_ports {data_in_pad[10]}]
set_input_delay -clock clk_pad  1.06  [get_ports {data_in_pad[9]}]
set_input_delay -clock clk_pad  1.06  [get_ports {data_in_pad[8]}]
set_input_delay -clock clk_pad  1.06  [get_ports {data_in_pad[7]}]
set_input_delay -clock clk_pad  1.06  [get_ports {data_in_pad[6]}]
set_input_delay -clock clk_pad  1.06  [get_ports {data_in_pad[5]}]
set_input_delay -clock clk_pad  1.06  [get_ports {data_in_pad[4]}]
set_input_delay -clock clk_pad  1.06  [get_ports {data_in_pad[3]}]
set_input_delay -clock clk_pad  1.06  [get_ports {data_in_pad[2]}]
set_input_delay -clock clk_pad  1.06  [get_ports {data_in_pad[1]}]
set_input_delay -clock clk_pad  1.06  [get_ports {data_in_pad[0]}]
set_input_delay -clock clk_pad  1.06  [get_ports in_valid_pad]
set_output_delay -clock clk_pad  1.06  [get_ports {data_out_pad[1]}]
set_output_delay -clock clk_pad  1.06  [get_ports {data_out_pad[0]}]
set_output_delay -clock clk_pad  1.06  [get_ports in_ready_pad]
set_output_delay -clock clk_pad  1.06  [get_ports out_en_pad]
set_input_transition -max 2  [get_ports mode_pad]
set_input_transition -min 2  [get_ports mode_pad]
set_input_transition -max 2  [get_ports {data_in_pad[15]}]
set_input_transition -min 2  [get_ports {data_in_pad[15]}]
set_input_transition -max 2  [get_ports {data_in_pad[14]}]
set_input_transition -min 2  [get_ports {data_in_pad[14]}]
set_input_transition -max 2  [get_ports {data_in_pad[13]}]
set_input_transition -min 2  [get_ports {data_in_pad[13]}]
set_input_transition -max 2  [get_ports {data_in_pad[12]}]
set_input_transition -min 2  [get_ports {data_in_pad[12]}]
set_input_transition -max 2  [get_ports {data_in_pad[11]}]
set_input_transition -min 2  [get_ports {data_in_pad[11]}]
set_input_transition -max 2  [get_ports {data_in_pad[10]}]
set_input_transition -min 2  [get_ports {data_in_pad[10]}]
set_input_transition -max 2  [get_ports {data_in_pad[9]}]
set_input_transition -min 2  [get_ports {data_in_pad[9]}]
set_input_transition -max 2  [get_ports {data_in_pad[8]}]
set_input_transition -min 2  [get_ports {data_in_pad[8]}]
set_input_transition -max 2  [get_ports {data_in_pad[7]}]
set_input_transition -min 2  [get_ports {data_in_pad[7]}]
set_input_transition -max 2  [get_ports {data_in_pad[6]}]
set_input_transition -min 2  [get_ports {data_in_pad[6]}]
set_input_transition -max 2  [get_ports {data_in_pad[5]}]
set_input_transition -min 2  [get_ports {data_in_pad[5]}]
set_input_transition -max 2  [get_ports {data_in_pad[4]}]
set_input_transition -min 2  [get_ports {data_in_pad[4]}]
set_input_transition -max 2  [get_ports {data_in_pad[3]}]
set_input_transition -min 2  [get_ports {data_in_pad[3]}]
set_input_transition -max 2  [get_ports {data_in_pad[2]}]
set_input_transition -min 2  [get_ports {data_in_pad[2]}]
set_input_transition -max 2  [get_ports {data_in_pad[1]}]
set_input_transition -min 2  [get_ports {data_in_pad[1]}]
set_input_transition -max 2  [get_ports {data_in_pad[0]}]
set_input_transition -min 2  [get_ports {data_in_pad[0]}]
set_input_transition -max 2  [get_ports in_valid_pad]
set_input_transition -min 2  [get_ports in_valid_pad]
