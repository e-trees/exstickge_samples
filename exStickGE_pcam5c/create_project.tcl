set project_dir    "./prj"
set project_name   "exstickge_pcam"
set project_target "xc7a200tsbg484-2"
set source_files { \
			../misc/axi4m_to_fifo.vhd \
			../misc/fifo_to_axi4m.vhd \
			../misc/resetgen.v \
			../misc/pulse_timer.v \
			../misc/idelayctrl_wrapper.v \
			../misc/axi4_lite_reader.sv \
			../misc/i2c_iface.vhd \
			../xilinx/2022.2/mig_a.prj \
			../edif/e7udpip_rgmii_artix7.edif \
			../edif/e7udpip_rgmii_artix7_stub.v \
		        ../vision/init_sccb_top.vhd \
		        ../digilent/AXI_BayerToRGB/hdl/AXI_BayerToRGB.vhd \
		        ../digilent/AXI_BayerToRGB/hdl/LineBuffer.vhd \
		        ../digilent/AXI_GammaCorrection/hdl/AXI_GammaCorrection.vhd \
		        ../digilent/AXI_GammaCorrection/hdl/StoredGammaCoefs.vhd \
		        ../vision/videoaxis2dram.v \
		        ../uplutils/udp_axi.v \
		        ./sources/top.v \
}

set constraint_files { \
			./sources/top.xdc \
		       }

set simulation_files { \
			../vision/init_sccb_top_tb.vhd \
			../xilinx/2022.2/sccb_bmem_tb.vhd \
		       }

create_project -force $project_name $project_dir -part $project_target
add_files -norecurse $source_files
add_files -fileset constrs_1 -norecurse $constraint_files

update_ip_catalog

import_ip -files ../xilinx/2022.2/fifo_36_1000.xci
import_ip -files ../xilinx/2022.2/fifo_37_1000_ft.xci
import_ip -files ../xilinx/2022.2/fifo_40_32_ft.xci
import_ip -files ../xilinx/2022.2/mig_7series_0.xci
import_ip -files ../xilinx/2022.2/mipi_csi2_rx_subsystem_0.xci
import_ip -files ../xilinx/2022.2/mipi_csi2_rx_subsystem_0_1.xci
import_ip -files ../xilinx/2022.2/sccb_bmem.xci
import_ip -files ../xilinx/2022.2/fifo_dataread.xci
import_ip -files ./ip/2022.2/clk_wiz_0.xci
import_ip -files ./ip/2022.2/clk_wiz_1.xci
import_ip -files ./ip/2022.2/ila_0.xci
import_ip -files ./ip/2022.2/ila_1.xci
import_ip -files ./ip/2022.2/ila_2.xci
import_ip -files ./ip/2022.2/ila_3.xci
import_ip -files ./ip/2022.2/vio_0.xci
import_ip -files ./ip/2022.2/vio_1.xci

set_property top top [current_fileset]
set_property target_constrs_file ./sources/top.xdc [current_fileset -constrset]

update_compile_order -fileset sources_1

add_files -fileset sim_1 -norecurse $simulation_files

update_compile_order -fileset sim_1

reset_project

set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
set_property strategy Performance_ExplorePostRoutePhysOpt [get_runs impl_1]

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
