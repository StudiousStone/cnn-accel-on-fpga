set_global_assignment -entity "fpdiv14" -library "lib_fpdiv14" -name IP_TOOL_NAME "altera_fp_functions"
set_global_assignment -entity "fpdiv14" -library "lib_fpdiv14" -name IP_TOOL_VERSION "15.1"
set_global_assignment -entity "fpdiv14" -library "lib_fpdiv14" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_fpdiv14" -name SPD_FILE [file join $::quartus(sip_path) "fpdiv14.spd"]

set_global_assignment -library "lib_fpdiv14" -name MISC_FILE [file join $::quartus(sip_path) "fpdiv14_sim/fpdiv14_memoryC0_uid146_invTables_lutmem.hex"]
set_global_assignment -library "lib_fpdiv14" -name MISC_FILE [file join $::quartus(sip_path) "fpdiv14_sim/fpdiv14_memoryC0_uid147_invTables_lutmem.hex"]
set_global_assignment -library "lib_fpdiv14" -name MISC_FILE [file join $::quartus(sip_path) "fpdiv14_sim/fpdiv14_memoryC1_uid150_invTables_lutmem.hex"]
set_global_assignment -library "lib_fpdiv14" -name MISC_FILE [file join $::quartus(sip_path) "fpdiv14_sim/fpdiv14_memoryC1_uid151_invTables_lutmem.hex"]
set_global_assignment -library "lib_fpdiv14" -name MISC_FILE [file join $::quartus(sip_path) "fpdiv14_sim/fpdiv14_memoryC2_uid154_invTables_lutmem.hex"]
set_global_assignment -library "lib_fpdiv14" -name MISC_FILE [file join $::quartus(sip_path) "fpdiv14_sim/fpdiv14.vo"]
