set project_dir    "./prj_vhdl"
set project_name   "exstickge_simple_udpsend"
set project_target "xc7a200tsbg484-2"
set source_files { \
			./sources/top.v \
			./sources/simple_udpsend.vhd \
			../misc/resetgen.v \
			../misc/pulse_timer.v \
			../misc/idelayctrl_wrapper.v \
			../edif/e7udpip_rgmii_artix7_stub.v \
			../edif/e7udpip_rgmii_artix7.edif \
}

set constraint_files { \
			./sources/top.xdc \
		       }

set simulation_files { \
		       }

create_project -force $project_name $project_dir -part $project_target
add_files -norecurse $source_files
add_files -fileset constrs_1 -norecurse $constraint_files

update_ip_catalog

import_ip -files ./ip/clk_wiz_1.xci
import_ip -files ./ip/clk_wiz_0.xci
import_ip -files ./ip/ila_0.xci

set_property top top [current_fileset]
set_property target_constrs_file ./sources/top.xdc [current_fileset -constrset]

update_compile_order -fileset sources_1

#add_files -fileset sim_1 -norecurse $simulation_files

update_compile_order -fileset sim_1

reset_project

#set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
#set_property strategy Performance_ExplorePostRoutePhysOpt [get_runs impl_1]

launch_runs synth_1 -jobs 4
wait_on_run synth_1

launch_runs impl_1 -jobs 4
wait_on_run impl_1
open_run impl_1
report_utilization -file [file join $project_dir "project.rpt"]
report_timing -file [file join $project_dir "project.rpt"] -append
 
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
close_project

quit
