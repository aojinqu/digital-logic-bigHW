#CLK
set_property IOSTANDARD LVCMOS33 [get_ports CLK]
set_property PACKAGE_PIN E3 [get_ports CLK]
#mp3
set_property IOSTANDARD LVCMOS33 [get_ports DREQ]
set_property IOSTANDARD LVCMOS33 [get_ports RSET]
set_property IOSTANDARD LVCMOS33 [get_ports XCS]
set_property IOSTANDARD LVCMOS33 [get_ports SCLK]
set_property IOSTANDARD LVCMOS33 [get_ports SI]
set_property IOSTANDARD LVCMOS33 [get_ports XDCS]
set_property PACKAGE_PIN F6 [get_ports RSET]
set_property PACKAGE_PIN J3 [get_ports SCLK]
set_property PACKAGE_PIN J4 [get_ports SI]
set_property PACKAGE_PIN E7 [get_ports XCS]
set_property PACKAGE_PIN K1 [get_ports XDCS]
set_property PACKAGE_PIN J2 [get_ports DREQ]


#vga
set_property IOSTANDARD LVCMOS33 [get_ports {O_BLUE[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {O_BLUE[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {O_BLUE[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {O_BLUE[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {O_GREEN[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {O_GREEN[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {O_GREEN[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {O_GREEN[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {O_RED[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {O_RED[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {O_RED[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {O_RED[0]}]
set_property PACKAGE_PIN A4 [get_ports {O_RED[3]}]
set_property PACKAGE_PIN C5 [get_ports {O_RED[2]}]
set_property PACKAGE_PIN B4 [get_ports {O_RED[1]}]
set_property PACKAGE_PIN A3 [get_ports {O_RED[0]}]
set_property PACKAGE_PIN A6 [get_ports {O_GREEN[3]}]
set_property PACKAGE_PIN B6 [get_ports {O_GREEN[2]}]
set_property PACKAGE_PIN A5 [get_ports {O_GREEN[1]}]
set_property PACKAGE_PIN C6 [get_ports {O_GREEN[0]}]
set_property PACKAGE_PIN D8 [get_ports {O_BLUE[3]}]
set_property PACKAGE_PIN D7 [get_ports {O_BLUE[2]}]
set_property PACKAGE_PIN C7 [get_ports {O_BLUE[1]}]
set_property PACKAGE_PIN B7 [get_ports {O_BLUE[0]}]


set_property IOSTANDARD LVCMOS33 [get_ports O_HS]
set_property IOSTANDARD LVCMOS33 [get_ports O_VS]
 set_property IOSTANDARD LVCMOS33 [get_ports RST_n]
set_property PACKAGE_PIN B11 [get_ports O_HS]
set_property PACKAGE_PIN B12 [get_ports O_VS]
 set_property PACKAGE_PIN J15 [get_ports RST_n]

# keyborad
set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS33} [get_ports usbCLK]
set_property -dict {PACKAGE_PIN B2 IOSTANDARD LVCMOS33} [get_ports usbDATA]

# display
set_property PACKAGE_PIN   T10  [get_ports display[0]]
set_property IOSTANDARD LVCMOS33 [get_ports display[0]]
set_property PACKAGE_PIN   R10  [get_ports display[1]]
set_property IOSTANDARD LVCMOS33 [get_ports display[1]]
set_property PACKAGE_PIN   K16  [get_ports display[2]]
set_property IOSTANDARD LVCMOS33 [get_ports display[2]]
set_property PACKAGE_PIN   K13  [get_ports display[3]]
set_property IOSTANDARD LVCMOS33 [get_ports display[3]]
set_property PACKAGE_PIN   P15  [get_ports display[4]]
set_property IOSTANDARD LVCMOS33 [get_ports display[4]]
set_property PACKAGE_PIN   T11  [get_ports display[5]]
set_property IOSTANDARD LVCMOS33 [get_ports display[5]]
set_property PACKAGE_PIN   L18  [get_ports display[6]]
set_property IOSTANDARD LVCMOS33 [get_ports display[6]]