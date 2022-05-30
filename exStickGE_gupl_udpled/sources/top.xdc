set_property -dict {PACKAGE_PIN AA14 IOSTANDARD LVCMOS33} [get_ports {GEPHY_RD[3]}]
set_property -dict {PACKAGE_PIN Y13  IOSTANDARD LVCMOS33} [get_ports {GEPHY_RD[2]}]
set_property -dict {PACKAGE_PIN AB15 IOSTANDARD LVCMOS33} [get_ports {GEPHY_RD[1]}]
set_property -dict {PACKAGE_PIN AA15 IOSTANDARD LVCMOS33} [get_ports {GEPHY_RD[0]}]
set_property -dict {PACKAGE_PIN AB17 IOSTANDARD LVCMOS33} [get_ports {GEPHY_TD[3]}]
set_property -dict {PACKAGE_PIN AB16 IOSTANDARD LVCMOS33} [get_ports {GEPHY_TD[2]}]
set_property -dict {PACKAGE_PIN AA16 IOSTANDARD LVCMOS33} [get_ports {GEPHY_TD[1]}]
set_property -dict {PACKAGE_PIN Y16  IOSTANDARD LVCMOS33} [get_ports {GEPHY_TD[0]}]
set_property -dict {PACKAGE_PIN W11  IOSTANDARD LVCMOS33} [get_ports GEPHY_MAC_CLK]
set_property -dict {PACKAGE_PIN T16  IOSTANDARD LVCMOS33} [get_ports GEPHY_PMEB]
set_property -dict {PACKAGE_PIN Y11  IOSTANDARD LVCMOS33} [get_ports GEPHY_RCK]
set_property -dict {PACKAGE_PIN U16  IOSTANDARD LVCMOS33} [get_ports GEPHY_RST_N]
set_property -dict {PACKAGE_PIN AA9  IOSTANDARD LVCMOS33} [get_ports GEPHY_RXDV_ER]
set_property -dict {PACKAGE_PIN AB13 IOSTANDARD LVCMOS33} [get_ports GEPHY_TCK]
set_property -dict {PACKAGE_PIN AA13 IOSTANDARD LVCMOS33} [get_ports GEPHY_TXEN_ER]
set_property -dict {PACKAGE_PIN AA11 IOSTANDARD LVCMOS33} [get_ports GEPHY_INT_N]
set_property -dict {PACKAGE_PIN AA10 IOSTANDARD LVCMOS33} [get_ports GEPHY_MDC]
set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVCMOS33} [get_ports GEPHY_MDIO]

set_property -dict {PACKAGE_PIN E21  IOSTANDARD LVCMOS33} [get_ports LED0]
set_property -dict {PACKAGE_PIN D21  IOSTANDARD LVCMOS33} [get_ports LED1]
set_property -dict {PACKAGE_PIN G22  IOSTANDARD LVCMOS33} [get_ports LED2]
set_property -dict {PACKAGE_PIN H4   IOSTANDARD LVDS_25}  [get_ports sys_clk_p]
set_property -dict {PACKAGE_PIN G4   IOSTANDARD LVDS_25}  [get_ports sys_clk_n]
set_property -dict {PACKAGE_PIN D19  IOSTANDARD LVCMOS33} [get_ports sys_rst_n]


create_clock -period 5.000 -name sysclk [get_ports sys_clk_p]
create_clock -period 8.000 -name macclk -waveform {0.000 4.000} [get_ports GEPHY_MAC_CLK]
create_clock -period 8.000 -name rgmii_rxclk -waveform {2.200 6.200} [get_ports GEPHY_RCK]

## 90-degree shift from RCK
set_input_delay -clock [get_clocks rgmii_rxclk] -clock_fall -min -add_delay 1.000 [get_ports {GEPHY_RD[*]}]
set_input_delay -clock [get_clocks rgmii_rxclk] -clock_fall -max -add_delay 3.000 [get_ports {GEPHY_RD[*]}]
set_input_delay -clock [get_clocks rgmii_rxclk] -min -add_delay 1.000 [get_ports {GEPHY_RD[*]}]
set_input_delay -clock [get_clocks rgmii_rxclk] -max -add_delay 3.000 [get_ports {GEPHY_RD[*]}]
set_input_delay -clock [get_clocks rgmii_rxclk] -clock_fall -min -add_delay 1.000 [get_ports GEPHY_RXDV_ER]
set_input_delay -clock [get_clocks rgmii_rxclk] -clock_fall -max -add_delay 3.000 [get_ports GEPHY_RXDV_ER]
set_input_delay -clock [get_clocks rgmii_rxclk] -min -add_delay 1.000 [get_ports GEPHY_RXDV_ER]
set_input_delay -clock [get_clocks rgmii_rxclk] -max -add_delay 3.000 [get_ports GEPHY_RXDV_ER]

## 90-degree shift from TCK
create_generated_clock -name GEPHY_TCK -source [get_pins u_e7udpip/u_e7udpip/u_ether/u_gmiitx/miitxregs_a7.txclk_ddr/C] -divide_by 1 [get_ports GEPHY_TCK]
set_output_delay -clock [get_clocks GEPHY_TCK] -clock_fall -min -add_delay 1.000 [get_ports {GEPHY_TD[*]}]
set_output_delay -clock [get_clocks GEPHY_TCK] -clock_fall -max -add_delay 3.000 [get_ports {GEPHY_TD[*]}]
set_output_delay -clock [get_clocks GEPHY_TCK] -max -add_delay 3.000 [get_ports {GEPHY_TD[*]}]
set_output_delay -clock [get_clocks GEPHY_TCK] -max -add_delay 3.000 [get_ports {GEPHY_TD[*]}]

set_output_delay -clock [get_clocks GEPHY_TCK] -clock_fall -min -add_delay 1.000 [get_ports GEPHY_TXEN_ER]
set_output_delay -clock [get_clocks GEPHY_TCK] -clock_fall -max -add_delay 3.000 [get_ports GEPHY_TXEN_ER]
set_output_delay -clock [get_clocks GEPHY_TCK] -min -add_delay 1.000 [get_ports GEPHY_TXEN_ER]
set_output_delay -clock [get_clocks GEPHY_TCK] -max -add_delay 3.000 [get_ports GEPHY_TXEN_ER]

create_pblock pblock_u_e7udpip
add_cells_to_pblock [get_pblocks pblock_u_e7udpip] [get_cells -quiet [list u_e7udpip]]
resize_pblock [get_pblocks pblock_u_e7udpip] -add {CLOCKREGION_X0Y1:CLOCKREGION_X0Y1}


set_false_path -from [get_clocks rgmii_rxclk] -to [get_clocks -of_objects [get_pins clk_wiz_1_i/inst/mmcm_adv_inst/CLKOUT1]]
set_false_path -from [get_clocks -of_objects [get_pins clk_wiz_1_i/inst/mmcm_adv_inst/CLKOUT1]] -to [get_clocks rgmii_rxclk]

set_property OFFCHIP_TERM NONE [get_ports GEPHY_RST_N]
set_property OFFCHIP_TERM NONE [get_ports GEPHY_TCK]
set_property OFFCHIP_TERM NONE [get_ports GEPHY_TD[0]]
set_property OFFCHIP_TERM NONE [get_ports GEPHY_TD[1]]
set_property OFFCHIP_TERM NONE [get_ports GEPHY_TD[2]]
set_property OFFCHIP_TERM NONE [get_ports GEPHY_TD[3]]
set_property OFFCHIP_TERM NONE [get_ports GEPHY_TXEN_ER]
set_property OFFCHIP_TERM NONE [get_ports LED0]
set_property OFFCHIP_TERM NONE [get_ports LED1]
set_property OFFCHIP_TERM NONE [get_ports LED2]

set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
