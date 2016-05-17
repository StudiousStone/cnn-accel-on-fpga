set_global_assignment -entity "avlon_MM_slave" -library "lib_avlon_MM_slave" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "avlon_MM_slave" -library "lib_avlon_MM_slave" -name IP_TOOL_VERSION "15.1"
set_global_assignment -entity "avlon_MM_slave" -library "lib_avlon_MM_slave" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_avlon_MM_slave" -name SPD_FILE [file join $::quartus(sip_path) "../avlon_MM_slave.spd"]
set_global_assignment -library "lib_avlon_MM_slave" -name MISC_FILE [file join $::quartus(sip_path) "../../avlon_MM_slave.qsys"]

set_global_assignment -library "lib_avlon_MM_slave" -name MISC_FILE [file join $::quartus(sip_path) "avlon_MM_slave.v"]
set_global_assignment -library "lib_avlon_MM_slave" -name MISC_FILE [file join $::quartus(sip_path) "submodules/verbosity_pkg.sv"]
set_global_assignment -library "lib_avlon_MM_slave" -name MISC_FILE [file join $::quartus(sip_path) "submodules/avalon_mm_pkg.sv"]
set_global_assignment -library "lib_avlon_MM_slave" -name MISC_FILE [file join $::quartus(sip_path) "submodules/avalon_utilities_pkg.sv"]
set_global_assignment -library "lib_avlon_MM_slave" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_avalon_mm_slave_bfm.sv"]
