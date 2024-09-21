#read_file -format sverilog {../src/top.sv}

analyze -vcs {incdir+../src+../src/AXI} -format sverilog {../src/top.sv}
elaborate top
current_design top
link
uniquify
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]

source ../script/DC.sdc

compile
remove_unconnected_ports -blast_buses [get_cells * -hier]
write_file -format verilog -hier -output ../syn/top_syn.v
write_sdf -version 2.1 -context verilog -load_delay net ../syn/top_syn.sdf
report_timing > ../syn/timing.log
report_area > ../syn/area.log
