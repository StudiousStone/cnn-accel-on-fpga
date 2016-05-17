-- ------------------------------------------------------------------------- 
-- Altera DSP Builder Advanced Flow Tools Release Version 15.1
-- Quartus Prime development tool and MATLAB/Simulink Interface
-- 
-- Legal Notice: Copyright 2015 Altera Corporation.  All rights reserved.
-- Your use of  Altera  Corporation's design tools,  logic functions and other
-- software and tools,  and its AMPP  partner logic functions, and  any output
-- files  any of the  foregoing  device programming or simulation files),  and
-- any associated  documentation or information are expressly subject  to  the
-- terms and conditions  of the Altera Program License Subscription Agreement,
-- Altera  MegaCore  Function  License  Agreement, or other applicable license
-- agreement,  including,  without limitation,  that your use  is for the sole
-- purpose of  programming  logic  devices  manufactured by Altera and sold by
-- Altera or its authorized  distributors.  Please  refer  to  the  applicable
-- agreement for further details.
-- ---------------------------------------------------------------------------

-- VHDL created from fpdiv14_0002
-- VHDL created on Wed May 04 16:36:49 2016


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;
use std.TextIO.all;
use work.dspba_library_package.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;
LIBRARY altera_lnsim;
USE altera_lnsim.altera_lnsim_components.altera_syncram;
LIBRARY lpm;
USE lpm.lpm_components.all;

entity fpdiv14_0002 is
    port (
        a : in std_logic_vector(31 downto 0);  -- float32_m23
        b : in std_logic_vector(31 downto 0);  -- float32_m23
        q : out std_logic_vector(31 downto 0);  -- float32_m23
        clk : in std_logic;
        areset : in std_logic
    );
end fpdiv14_0002;

architecture normal of fpdiv14_0002 is

    attribute altera_attribute : string;
    attribute altera_attribute of normal : architecture is "-name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON; -name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007";
    
    signal GND_q : STD_LOGIC_VECTOR (0 downto 0);
    signal VCC_q : STD_LOGIC_VECTOR (0 downto 0);
    signal cstBiasM1_uid6_fpDivTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal cstBias_uid7_fpDivTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal paddingY_uid15_fpDivTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal fracYZero_uid15_fpDivTest_a : STD_LOGIC_VECTOR (23 downto 0);
    signal fracYZero_uid15_fpDivTest_b : STD_LOGIC_VECTOR (23 downto 0);
    signal fracYZero_uid15_fpDivTest_q_i : STD_LOGIC_VECTOR (0 downto 0);
    signal fracYZero_uid15_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal cstAllOWE_uid18_fpDivTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal cstAllZWE_uid20_fpDivTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal fracXIsZero_uid25_fpDivTest_a : STD_LOGIC_VECTOR (22 downto 0);
    signal fracXIsZero_uid25_fpDivTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal fracXIsZero_uid25_fpDivTest_q_i : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid25_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid39_fpDivTest_a : STD_LOGIC_VECTOR (22 downto 0);
    signal fracXIsZero_uid39_fpDivTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal fracXIsZero_uid39_fpDivTest_q_i : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid39_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signR_uid46_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal signR_uid46_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal signR_uid46_fpDivTest_q_i : STD_LOGIC_VECTOR (0 downto 0);
    signal signR_uid46_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXmY_uid47_fpDivTest_a : STD_LOGIC_VECTOR (8 downto 0);
    signal expXmY_uid47_fpDivTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal expXmY_uid47_fpDivTest_o : STD_LOGIC_VECTOR (8 downto 0);
    signal expXmY_uid47_fpDivTest_q : STD_LOGIC_VECTOR (8 downto 0);
    signal z4_uid60_fpDivTest_q : STD_LOGIC_VECTOR (3 downto 0);
    signal zeroPaddingInAddition_uid74_fpDivTest_q : STD_LOGIC_VECTOR (23 downto 0);
    signal expFracPostRnd_uid76_fpDivTest_a : STD_LOGIC_VECTOR (36 downto 0);
    signal expFracPostRnd_uid76_fpDivTest_b : STD_LOGIC_VECTOR (36 downto 0);
    signal expFracPostRnd_uid76_fpDivTest_o : STD_LOGIC_VECTOR (36 downto 0);
    signal expFracPostRnd_uid76_fpDivTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal qDivProdExp_opA_uid94_fpDivTest_a : STD_LOGIC_VECTOR (8 downto 0);
    signal qDivProdExp_opA_uid94_fpDivTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal qDivProdExp_opA_uid94_fpDivTest_o : STD_LOGIC_VECTOR (8 downto 0);
    signal qDivProdExp_opA_uid94_fpDivTest_q : STD_LOGIC_VECTOR (8 downto 0);
    signal qDivProdExp_opBs_uid95_fpDivTest_a : STD_LOGIC_VECTOR (8 downto 0);
    signal qDivProdExp_opBs_uid95_fpDivTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal qDivProdExp_opBs_uid95_fpDivTest_o : STD_LOGIC_VECTOR (8 downto 0);
    signal qDivProdExp_opBs_uid95_fpDivTest_q : STD_LOGIC_VECTOR (8 downto 0);
    signal extraUlp_uid103_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal extraUlp_uid103_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal extraUlp_uid103_fpDivTest_q_i : STD_LOGIC_VECTOR (0 downto 0);
    signal extraUlp_uid103_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracRPreExcExt_uid105_fpDivTest_a : STD_LOGIC_VECTOR (23 downto 0);
    signal fracRPreExcExt_uid105_fpDivTest_b : STD_LOGIC_VECTOR (23 downto 0);
    signal fracRPreExcExt_uid105_fpDivTest_o : STD_LOGIC_VECTOR (23 downto 0);
    signal fracRPreExcExt_uid105_fpDivTest_q : STD_LOGIC_VECTOR (23 downto 0);
    signal expRPreExc_uid112_fpDivTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal expRPreExc_uid112_fpDivTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal expUdf_uid115_fpDivTest_a : STD_LOGIC_VECTOR (13 downto 0);
    signal expUdf_uid115_fpDivTest_b : STD_LOGIC_VECTOR (13 downto 0);
    signal expUdf_uid115_fpDivTest_o : STD_LOGIC_VECTOR (13 downto 0);
    signal expUdf_uid115_fpDivTest_cin : STD_LOGIC_VECTOR (0 downto 0);
    signal expUdf_uid115_fpDivTest_n : STD_LOGIC_VECTOR (0 downto 0);
    signal expOvf_uid118_fpDivTest_a : STD_LOGIC_VECTOR (13 downto 0);
    signal expOvf_uid118_fpDivTest_b : STD_LOGIC_VECTOR (13 downto 0);
    signal expOvf_uid118_fpDivTest_o : STD_LOGIC_VECTOR (13 downto 0);
    signal expOvf_uid118_fpDivTest_cin : STD_LOGIC_VECTOR (0 downto 0);
    signal expOvf_uid118_fpDivTest_n : STD_LOGIC_VECTOR (0 downto 0);
    signal excREnc_uid133_fpDivTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal oneFracRPostExc2_uid134_fpDivTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal fracRPostExc_uid137_fpDivTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal fracRPostExc_uid137_fpDivTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal sRPostExc_uid143_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal sRPostExc_uid143_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal sRPostExc_uid143_fpDivTest_q_i : STD_LOGIC_VECTOR (0 downto 0);
    signal sRPostExc_uid143_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal s1sumAHighB_uid164_invPolyEval_a : STD_LOGIC_VECTOR (22 downto 0);
    signal s1sumAHighB_uid164_invPolyEval_b : STD_LOGIC_VECTOR (22 downto 0);
    signal s1sumAHighB_uid164_invPolyEval_o : STD_LOGIC_VECTOR (22 downto 0);
    signal s1sumAHighB_uid164_invPolyEval_q : STD_LOGIC_VECTOR (22 downto 0);
    signal memoryC0_uid146_invTables_lutmem_reset0 : std_logic;
    signal memoryC0_uid146_invTables_lutmem_ia : STD_LOGIC_VECTOR (19 downto 0);
    signal memoryC0_uid146_invTables_lutmem_aa : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC0_uid146_invTables_lutmem_ab : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC0_uid146_invTables_lutmem_ir : STD_LOGIC_VECTOR (19 downto 0);
    signal memoryC0_uid146_invTables_lutmem_r : STD_LOGIC_VECTOR (19 downto 0);
    signal memoryC0_uid147_invTables_lutmem_reset0 : std_logic;
    signal memoryC0_uid147_invTables_lutmem_ia : STD_LOGIC_VECTOR (11 downto 0);
    signal memoryC0_uid147_invTables_lutmem_aa : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC0_uid147_invTables_lutmem_ab : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC0_uid147_invTables_lutmem_ir : STD_LOGIC_VECTOR (11 downto 0);
    signal memoryC0_uid147_invTables_lutmem_r : STD_LOGIC_VECTOR (11 downto 0);
    signal memoryC1_uid150_invTables_lutmem_reset0 : std_logic;
    signal memoryC1_uid150_invTables_lutmem_ia : STD_LOGIC_VECTOR (19 downto 0);
    signal memoryC1_uid150_invTables_lutmem_aa : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC1_uid150_invTables_lutmem_ab : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC1_uid150_invTables_lutmem_ir : STD_LOGIC_VECTOR (19 downto 0);
    signal memoryC1_uid150_invTables_lutmem_r : STD_LOGIC_VECTOR (19 downto 0);
    signal memoryC1_uid151_invTables_lutmem_reset0 : std_logic;
    signal memoryC1_uid151_invTables_lutmem_ia : STD_LOGIC_VECTOR (1 downto 0);
    signal memoryC1_uid151_invTables_lutmem_aa : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC1_uid151_invTables_lutmem_ab : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC1_uid151_invTables_lutmem_ir : STD_LOGIC_VECTOR (1 downto 0);
    signal memoryC1_uid151_invTables_lutmem_r : STD_LOGIC_VECTOR (1 downto 0);
    signal memoryC2_uid154_invTables_lutmem_reset0 : std_logic;
    signal memoryC2_uid154_invTables_lutmem_ia : STD_LOGIC_VECTOR (12 downto 0);
    signal memoryC2_uid154_invTables_lutmem_aa : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC2_uid154_invTables_lutmem_ab : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC2_uid154_invTables_lutmem_ir : STD_LOGIC_VECTOR (12 downto 0);
    signal memoryC2_uid154_invTables_lutmem_r : STD_LOGIC_VECTOR (12 downto 0);
    type qDivProd_uid89_fpDivTest_cma_a_type is array(0 to 0) of UNSIGNED(24 downto 0);
    signal qDivProd_uid89_fpDivTest_cma_a0 : qDivProd_uid89_fpDivTest_cma_a_type;
    attribute preserve : boolean;
    attribute preserve of qDivProd_uid89_fpDivTest_cma_a0 : signal is true;
    type qDivProd_uid89_fpDivTest_cma_c_type is array(0 to 0) of UNSIGNED(23 downto 0);
    signal qDivProd_uid89_fpDivTest_cma_c0 : qDivProd_uid89_fpDivTest_cma_c_type;
    attribute preserve of qDivProd_uid89_fpDivTest_cma_c0 : signal is true;
    type qDivProd_uid89_fpDivTest_cma_p_type is array(0 to 0) of UNSIGNED(48 downto 0);
    signal qDivProd_uid89_fpDivTest_cma_p : qDivProd_uid89_fpDivTest_cma_p_type;
    type qDivProd_uid89_fpDivTest_cma_u_type is array(0 to 0) of UNSIGNED(48 downto 0);
    signal qDivProd_uid89_fpDivTest_cma_u : qDivProd_uid89_fpDivTest_cma_u_type;
    type qDivProd_uid89_fpDivTest_cma_w_type is array(0 to 0) of UNSIGNED(48 downto 0);
    signal qDivProd_uid89_fpDivTest_cma_w : qDivProd_uid89_fpDivTest_cma_w_type;
    type qDivProd_uid89_fpDivTest_cma_x_type is array(0 to 0) of UNSIGNED(48 downto 0);
    signal qDivProd_uid89_fpDivTest_cma_x : qDivProd_uid89_fpDivTest_cma_x_type;
    type qDivProd_uid89_fpDivTest_cma_y_type is array(0 to 0) of UNSIGNED(48 downto 0);
    signal qDivProd_uid89_fpDivTest_cma_y : qDivProd_uid89_fpDivTest_cma_y_type;
    type qDivProd_uid89_fpDivTest_cma_s_type is array(0 to 0) of UNSIGNED(48 downto 0);
    signal qDivProd_uid89_fpDivTest_cma_s : qDivProd_uid89_fpDivTest_cma_s_type;
    signal qDivProd_uid89_fpDivTest_cma_qq : STD_LOGIC_VECTOR (48 downto 0);
    signal qDivProd_uid89_fpDivTest_cma_q : STD_LOGIC_VECTOR (48 downto 0);
    type prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_a_type is array(0 to 0) of UNSIGNED(26 downto 0);
    signal prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_a0 : prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_a_type;
    attribute preserve of prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_a0 : signal is true;
    type prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_c_type is array(0 to 0) of UNSIGNED(23 downto 0);
    signal prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_c0 : prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_c_type;
    attribute preserve of prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_c0 : signal is true;
    type prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_p_type is array(0 to 0) of UNSIGNED(50 downto 0);
    signal prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_p : prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_p_type;
    type prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_u_type is array(0 to 0) of UNSIGNED(50 downto 0);
    signal prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_u : prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_u_type;
    type prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_w_type is array(0 to 0) of UNSIGNED(50 downto 0);
    signal prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_w : prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_w_type;
    type prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_x_type is array(0 to 0) of UNSIGNED(50 downto 0);
    signal prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_x : prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_x_type;
    type prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_y_type is array(0 to 0) of UNSIGNED(50 downto 0);
    signal prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_y : prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_y_type;
    type prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_s_type is array(0 to 0) of UNSIGNED(50 downto 0);
    signal prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_s : prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_s_type;
    signal prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_qq : STD_LOGIC_VECTOR (50 downto 0);
    signal prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_q : STD_LOGIC_VECTOR (50 downto 0);
    type prodXY_uid176_pT1_uid161_invPolyEval_cma_a_type is array(0 to 0) of UNSIGNED(12 downto 0);
    signal prodXY_uid176_pT1_uid161_invPolyEval_cma_a0 : prodXY_uid176_pT1_uid161_invPolyEval_cma_a_type;
    attribute preserve of prodXY_uid176_pT1_uid161_invPolyEval_cma_a0 : signal is true;
    type prodXY_uid176_pT1_uid161_invPolyEval_cma_c_type is array(0 to 0) of SIGNED(12 downto 0);
    signal prodXY_uid176_pT1_uid161_invPolyEval_cma_c0 : prodXY_uid176_pT1_uid161_invPolyEval_cma_c_type;
    attribute preserve of prodXY_uid176_pT1_uid161_invPolyEval_cma_c0 : signal is true;
    type prodXY_uid176_pT1_uid161_invPolyEval_cma_l_type is array(0 to 0) of SIGNED(13 downto 0);
    signal prodXY_uid176_pT1_uid161_invPolyEval_cma_l : prodXY_uid176_pT1_uid161_invPolyEval_cma_l_type;
    type prodXY_uid176_pT1_uid161_invPolyEval_cma_p_type is array(0 to 0) of SIGNED(26 downto 0);
    signal prodXY_uid176_pT1_uid161_invPolyEval_cma_p : prodXY_uid176_pT1_uid161_invPolyEval_cma_p_type;
    type prodXY_uid176_pT1_uid161_invPolyEval_cma_u_type is array(0 to 0) of SIGNED(26 downto 0);
    signal prodXY_uid176_pT1_uid161_invPolyEval_cma_u : prodXY_uid176_pT1_uid161_invPolyEval_cma_u_type;
    type prodXY_uid176_pT1_uid161_invPolyEval_cma_w_type is array(0 to 0) of SIGNED(26 downto 0);
    signal prodXY_uid176_pT1_uid161_invPolyEval_cma_w : prodXY_uid176_pT1_uid161_invPolyEval_cma_w_type;
    type prodXY_uid176_pT1_uid161_invPolyEval_cma_x_type is array(0 to 0) of SIGNED(26 downto 0);
    signal prodXY_uid176_pT1_uid161_invPolyEval_cma_x : prodXY_uid176_pT1_uid161_invPolyEval_cma_x_type;
    type prodXY_uid176_pT1_uid161_invPolyEval_cma_y_type is array(0 to 0) of SIGNED(26 downto 0);
    signal prodXY_uid176_pT1_uid161_invPolyEval_cma_y : prodXY_uid176_pT1_uid161_invPolyEval_cma_y_type;
    type prodXY_uid176_pT1_uid161_invPolyEval_cma_s_type is array(0 to 0) of SIGNED(26 downto 0);
    signal prodXY_uid176_pT1_uid161_invPolyEval_cma_s : prodXY_uid176_pT1_uid161_invPolyEval_cma_s_type;
    signal prodXY_uid176_pT1_uid161_invPolyEval_cma_qq : STD_LOGIC_VECTOR (25 downto 0);
    signal prodXY_uid176_pT1_uid161_invPolyEval_cma_q : STD_LOGIC_VECTOR (25 downto 0);
    type prodXY_uid179_pT2_uid167_invPolyEval_cma_a_type is array(0 to 0) of UNSIGNED(13 downto 0);
    signal prodXY_uid179_pT2_uid167_invPolyEval_cma_a0 : prodXY_uid179_pT2_uid167_invPolyEval_cma_a_type;
    attribute preserve of prodXY_uid179_pT2_uid167_invPolyEval_cma_a0 : signal is true;
    type prodXY_uid179_pT2_uid167_invPolyEval_cma_c_type is array(0 to 0) of SIGNED(23 downto 0);
    signal prodXY_uid179_pT2_uid167_invPolyEval_cma_c0 : prodXY_uid179_pT2_uid167_invPolyEval_cma_c_type;
    attribute preserve of prodXY_uid179_pT2_uid167_invPolyEval_cma_c0 : signal is true;
    type prodXY_uid179_pT2_uid167_invPolyEval_cma_l_type is array(0 to 0) of SIGNED(14 downto 0);
    signal prodXY_uid179_pT2_uid167_invPolyEval_cma_l : prodXY_uid179_pT2_uid167_invPolyEval_cma_l_type;
    type prodXY_uid179_pT2_uid167_invPolyEval_cma_p_type is array(0 to 0) of SIGNED(38 downto 0);
    signal prodXY_uid179_pT2_uid167_invPolyEval_cma_p : prodXY_uid179_pT2_uid167_invPolyEval_cma_p_type;
    type prodXY_uid179_pT2_uid167_invPolyEval_cma_u_type is array(0 to 0) of SIGNED(38 downto 0);
    signal prodXY_uid179_pT2_uid167_invPolyEval_cma_u : prodXY_uid179_pT2_uid167_invPolyEval_cma_u_type;
    type prodXY_uid179_pT2_uid167_invPolyEval_cma_w_type is array(0 to 0) of SIGNED(38 downto 0);
    signal prodXY_uid179_pT2_uid167_invPolyEval_cma_w : prodXY_uid179_pT2_uid167_invPolyEval_cma_w_type;
    type prodXY_uid179_pT2_uid167_invPolyEval_cma_x_type is array(0 to 0) of SIGNED(38 downto 0);
    signal prodXY_uid179_pT2_uid167_invPolyEval_cma_x : prodXY_uid179_pT2_uid167_invPolyEval_cma_x_type;
    type prodXY_uid179_pT2_uid167_invPolyEval_cma_y_type is array(0 to 0) of SIGNED(38 downto 0);
    signal prodXY_uid179_pT2_uid167_invPolyEval_cma_y : prodXY_uid179_pT2_uid167_invPolyEval_cma_y_type;
    type prodXY_uid179_pT2_uid167_invPolyEval_cma_s_type is array(0 to 0) of SIGNED(38 downto 0);
    signal prodXY_uid179_pT2_uid167_invPolyEval_cma_s : prodXY_uid179_pT2_uid167_invPolyEval_cma_s_type;
    signal prodXY_uid179_pT2_uid167_invPolyEval_cma_qq : STD_LOGIC_VECTOR (37 downto 0);
    signal prodXY_uid179_pT2_uid167_invPolyEval_cma_q : STD_LOGIC_VECTOR (37 downto 0);
    signal redist0_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist1_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist3_q : STD_LOGIC_VECTOR (31 downto 0);
    signal redist4_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist5_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist6_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist7_q : STD_LOGIC_VECTOR (2 downto 0);
    signal redist9_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist10_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist11_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist12_q : STD_LOGIC_VECTOR (30 downto 0);
    signal redist13_q : STD_LOGIC_VECTOR (30 downto 0);
    signal redist14_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist15_q : STD_LOGIC_VECTOR (8 downto 0);
    signal redist16_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist17_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist18_q : STD_LOGIC_VECTOR (34 downto 0);
    signal redist19_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist20_q : STD_LOGIC_VECTOR (23 downto 0);
    signal redist21_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist22_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist23_q : STD_LOGIC_VECTOR (26 downto 0);
    signal redist24_q : STD_LOGIC_VECTOR (13 downto 0);
    signal redist25_q : STD_LOGIC_VECTOR (13 downto 0);
    signal redist26_q : STD_LOGIC_VECTOR (8 downto 0);
    signal redist27_q : STD_LOGIC_VECTOR (8 downto 0);
    signal redist28_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist30_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist32_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist34_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist35_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist37_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist8_outputreg_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist8_mem_reset0 : std_logic;
    signal redist8_mem_ia : STD_LOGIC_VECTOR (22 downto 0);
    signal redist8_mem_aa : STD_LOGIC_VECTOR (1 downto 0);
    signal redist8_mem_ab : STD_LOGIC_VECTOR (1 downto 0);
    signal redist8_mem_iq : STD_LOGIC_VECTOR (22 downto 0);
    signal redist8_mem_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist8_rdcnt_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist8_rdcnt_i : UNSIGNED (1 downto 0);
    attribute preserve of redist8_rdcnt_i : signal is true;
    signal redist8_rdcnt_eq : std_logic;
    attribute preserve of redist8_rdcnt_eq : signal is true;
    signal redist8_wraddr_q : STD_LOGIC_VECTOR (1 downto 0);
    signal redist8_mem_top_q : STD_LOGIC_VECTOR (2 downto 0);
    signal redist8_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist8_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    attribute preserve of redist8_sticky_ena_q : signal is true;
    signal redist12_inputreg_q : STD_LOGIC_VECTOR (30 downto 0);
    signal redist17_outputreg_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist29_outputreg_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist29_mem_reset0 : std_logic;
    signal redist29_mem_ia : STD_LOGIC_VECTOR (22 downto 0);
    signal redist29_mem_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal redist29_mem_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal redist29_mem_iq : STD_LOGIC_VECTOR (22 downto 0);
    signal redist29_mem_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist29_rdcnt_q : STD_LOGIC_VECTOR (2 downto 0);
    signal redist29_rdcnt_i : UNSIGNED (2 downto 0);
    attribute preserve of redist29_rdcnt_i : signal is true;
    signal redist29_wraddr_q : STD_LOGIC_VECTOR (2 downto 0);
    signal redist29_mem_top_q : STD_LOGIC_VECTOR (3 downto 0);
    signal redist29_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist29_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    attribute preserve of redist29_sticky_ena_q : signal is true;
    signal redist31_outputreg_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist31_mem_reset0 : std_logic;
    signal redist31_mem_ia : STD_LOGIC_VECTOR (7 downto 0);
    signal redist31_mem_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal redist31_mem_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal redist31_mem_iq : STD_LOGIC_VECTOR (7 downto 0);
    signal redist31_mem_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist31_rdcnt_q : STD_LOGIC_VECTOR (2 downto 0);
    signal redist31_rdcnt_i : UNSIGNED (2 downto 0);
    attribute preserve of redist31_rdcnt_i : signal is true;
    signal redist31_wraddr_q : STD_LOGIC_VECTOR (2 downto 0);
    signal redist31_mem_top_q : STD_LOGIC_VECTOR (3 downto 0);
    signal redist31_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist31_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    attribute preserve of redist31_sticky_ena_q : signal is true;
    signal redist33_outputreg_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist33_mem_reset0 : std_logic;
    signal redist33_mem_ia : STD_LOGIC_VECTOR (22 downto 0);
    signal redist33_mem_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal redist33_mem_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal redist33_mem_iq : STD_LOGIC_VECTOR (22 downto 0);
    signal redist33_mem_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist33_rdcnt_q : STD_LOGIC_VECTOR (2 downto 0);
    signal redist33_rdcnt_i : UNSIGNED (2 downto 0);
    attribute preserve of redist33_rdcnt_i : signal is true;
    signal redist33_rdcnt_eq : std_logic;
    attribute preserve of redist33_rdcnt_eq : signal is true;
    signal redist33_wraddr_q : STD_LOGIC_VECTOR (2 downto 0);
    signal redist33_mem_top_q : STD_LOGIC_VECTOR (3 downto 0);
    signal redist33_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist33_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    attribute preserve of redist33_sticky_ena_q : signal is true;
    signal redist34_inputreg_q : STD_LOGIC_VECTOR (22 downto 0);
    signal redist36_outputreg_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist36_mem_reset0 : std_logic;
    signal redist36_mem_ia : STD_LOGIC_VECTOR (7 downto 0);
    signal redist36_mem_aa : STD_LOGIC_VECTOR (2 downto 0);
    signal redist36_mem_ab : STD_LOGIC_VECTOR (2 downto 0);
    signal redist36_mem_iq : STD_LOGIC_VECTOR (7 downto 0);
    signal redist36_mem_q : STD_LOGIC_VECTOR (7 downto 0);
    signal redist36_rdcnt_q : STD_LOGIC_VECTOR (2 downto 0);
    signal redist36_rdcnt_i : UNSIGNED (2 downto 0);
    attribute preserve of redist36_rdcnt_i : signal is true;
    signal redist36_wraddr_q : STD_LOGIC_VECTOR (2 downto 0);
    signal redist36_mem_top_q : STD_LOGIC_VECTOR (3 downto 0);
    signal redist36_cmpReg_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist36_sticky_ena_q : STD_LOGIC_VECTOR (0 downto 0);
    attribute preserve of redist36_sticky_ena_q : signal is true;
    signal updatedY_uid16_fpDivTest_q : STD_LOGIC_VECTOR (23 downto 0);
    signal qDividerProdLTX_uid101_fpDivTest_a : STD_LOGIC_VECTOR (33 downto 0);
    signal qDividerProdLTX_uid101_fpDivTest_b : STD_LOGIC_VECTOR (33 downto 0);
    signal qDividerProdLTX_uid101_fpDivTest_o : STD_LOGIC_VECTOR (33 downto 0);
    signal qDividerProdLTX_uid101_fpDivTest_cin : STD_LOGIC_VECTOR (0 downto 0);
    signal qDividerProdLTX_uid101_fpDivTest_c : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXExt_uid77_fpDivTest_q : STD_LOGIC_VECTOR (23 downto 0);
    signal excZ_x_uid23_fpDivTest_a : STD_LOGIC_VECTOR (7 downto 0);
    signal excZ_x_uid23_fpDivTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal excZ_x_uid23_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid24_fpDivTest_a : STD_LOGIC_VECTOR (7 downto 0);
    signal expXIsMax_uid24_fpDivTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal expXIsMax_uid24_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsNotZero_uid26_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsNotZero_uid26_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_x_uid27_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_x_uid27_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_x_uid27_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_x_uid28_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_x_uid28_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_x_uid28_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExpXIsMax_uid29_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal invExpXIsMax_uid29_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal InvExpXIsZero_uid30_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal InvExpXIsZero_uid30_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_x_uid31_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_x_uid31_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_x_uid31_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excZ_y_uid37_fpDivTest_a : STD_LOGIC_VECTOR (7 downto 0);
    signal excZ_y_uid37_fpDivTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal excZ_y_uid37_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid38_fpDivTest_a : STD_LOGIC_VECTOR (7 downto 0);
    signal expXIsMax_uid38_fpDivTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal expXIsMax_uid38_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsNotZero_uid40_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsNotZero_uid40_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_y_uid41_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_y_uid41_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_y_uid41_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_y_uid42_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_y_uid42_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_y_uid42_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExpXIsMax_uid43_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal invExpXIsMax_uid43_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal InvExpXIsZero_uid44_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal InvExpXIsZero_uid44_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_y_uid45_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_y_uid45_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_y_uid45_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expR_uid48_fpDivTest_a : STD_LOGIC_VECTOR (10 downto 0);
    signal expR_uid48_fpDivTest_b : STD_LOGIC_VECTOR (10 downto 0);
    signal expR_uid48_fpDivTest_o : STD_LOGIC_VECTOR (10 downto 0);
    signal expR_uid48_fpDivTest_q : STD_LOGIC_VECTOR (9 downto 0);
    signal expPostRndF_uid82_fpDivTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal expPostRndF_uid82_fpDivTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal qDivProdExp_uid96_fpDivTest_a : STD_LOGIC_VECTOR (11 downto 0);
    signal qDivProdExp_uid96_fpDivTest_b : STD_LOGIC_VECTOR (11 downto 0);
    signal qDivProdExp_uid96_fpDivTest_o : STD_LOGIC_VECTOR (11 downto 0);
    signal qDivProdExp_uid96_fpDivTest_q : STD_LOGIC_VECTOR (10 downto 0);
    signal zeroOverReg_uid119_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal zeroOverReg_uid119_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal zeroOverReg_uid119_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal regOverRegWithUf_uid120_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal regOverRegWithUf_uid120_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal regOverRegWithUf_uid120_fpDivTest_c : STD_LOGIC_VECTOR (0 downto 0);
    signal regOverRegWithUf_uid120_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal xRegOrZero_uid121_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal xRegOrZero_uid121_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal xRegOrZero_uid121_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal regOrZeroOverInf_uid122_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal regOrZeroOverInf_uid122_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal regOrZeroOverInf_uid122_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRZero_uid123_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal excRZero_uid123_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal excRZero_uid123_fpDivTest_c : STD_LOGIC_VECTOR (0 downto 0);
    signal excRZero_uid123_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXRYZ_uid124_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal excXRYZ_uid124_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal excXRYZ_uid124_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXRYROvf_uid125_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal excXRYROvf_uid125_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal excXRYROvf_uid125_fpDivTest_c : STD_LOGIC_VECTOR (0 downto 0);
    signal excXRYROvf_uid125_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXIYZ_uid126_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal excXIYZ_uid126_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal excXIYZ_uid126_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXIYR_uid127_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal excXIYR_uid127_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal excXIYR_uid127_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRInf_uid128_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal excRInf_uid128_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal excRInf_uid128_fpDivTest_c : STD_LOGIC_VECTOR (0 downto 0);
    signal excRInf_uid128_fpDivTest_d : STD_LOGIC_VECTOR (0 downto 0);
    signal excRInf_uid128_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXZYZ_uid129_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal excXZYZ_uid129_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal excXZYZ_uid129_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXIYI_uid130_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal excXIYI_uid130_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal excXIYI_uid130_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRNaN_uid131_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal excRNaN_uid131_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal excRNaN_uid131_fpDivTest_c : STD_LOGIC_VECTOR (0 downto 0);
    signal excRNaN_uid131_fpDivTest_d : STD_LOGIC_VECTOR (0 downto 0);
    signal excRNaN_uid131_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expRPostExc_uid141_fpDivTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal expRPostExc_uid141_fpDivTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal invExcRNaN_uid142_fpDivTest_a : STD_LOGIC_VECTOR (0 downto 0);
    signal invExcRNaN_uid142_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal s2sumAHighB_uid170_invPolyEval_a : STD_LOGIC_VECTOR (32 downto 0);
    signal s2sumAHighB_uid170_invPolyEval_b : STD_LOGIC_VECTOR (32 downto 0);
    signal s2sumAHighB_uid170_invPolyEval_o : STD_LOGIC_VECTOR (32 downto 0);
    signal s2sumAHighB_uid170_invPolyEval_q : STD_LOGIC_VECTOR (32 downto 0);
    signal lOAdded_uid57_fpDivTest_q : STD_LOGIC_VECTOR (23 downto 0);
    signal expFracPostRnd_uid75_fpDivTest_q : STD_LOGIC_VECTOR (25 downto 0);
    signal lOAdded_uid87_fpDivTest_q : STD_LOGIC_VECTOR (23 downto 0);
    signal redist8_cmp_a : STD_LOGIC_VECTOR (2 downto 0);
    signal redist8_cmp_b : STD_LOGIC_VECTOR (2 downto 0);
    signal redist8_cmp_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist8_notEnable_a : STD_LOGIC_VECTOR (0 downto 0);
    signal redist8_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist8_nor_a : STD_LOGIC_VECTOR (0 downto 0);
    signal redist8_nor_b : STD_LOGIC_VECTOR (0 downto 0);
    signal redist8_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist8_enaAnd_a : STD_LOGIC_VECTOR (0 downto 0);
    signal redist8_enaAnd_b : STD_LOGIC_VECTOR (0 downto 0);
    signal redist8_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist29_cmp_a : STD_LOGIC_VECTOR (3 downto 0);
    signal redist29_cmp_b : STD_LOGIC_VECTOR (3 downto 0);
    signal redist29_cmp_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist29_notEnable_a : STD_LOGIC_VECTOR (0 downto 0);
    signal redist29_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist29_nor_a : STD_LOGIC_VECTOR (0 downto 0);
    signal redist29_nor_b : STD_LOGIC_VECTOR (0 downto 0);
    signal redist29_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist29_enaAnd_a : STD_LOGIC_VECTOR (0 downto 0);
    signal redist29_enaAnd_b : STD_LOGIC_VECTOR (0 downto 0);
    signal redist29_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist31_cmp_a : STD_LOGIC_VECTOR (3 downto 0);
    signal redist31_cmp_b : STD_LOGIC_VECTOR (3 downto 0);
    signal redist31_cmp_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist31_notEnable_a : STD_LOGIC_VECTOR (0 downto 0);
    signal redist31_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist31_nor_a : STD_LOGIC_VECTOR (0 downto 0);
    signal redist31_nor_b : STD_LOGIC_VECTOR (0 downto 0);
    signal redist31_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist31_enaAnd_a : STD_LOGIC_VECTOR (0 downto 0);
    signal redist31_enaAnd_b : STD_LOGIC_VECTOR (0 downto 0);
    signal redist31_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist33_cmp_a : STD_LOGIC_VECTOR (3 downto 0);
    signal redist33_cmp_b : STD_LOGIC_VECTOR (3 downto 0);
    signal redist33_cmp_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist33_notEnable_a : STD_LOGIC_VECTOR (0 downto 0);
    signal redist33_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist33_nor_a : STD_LOGIC_VECTOR (0 downto 0);
    signal redist33_nor_b : STD_LOGIC_VECTOR (0 downto 0);
    signal redist33_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist33_enaAnd_a : STD_LOGIC_VECTOR (0 downto 0);
    signal redist33_enaAnd_b : STD_LOGIC_VECTOR (0 downto 0);
    signal redist33_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist36_cmp_a : STD_LOGIC_VECTOR (3 downto 0);
    signal redist36_cmp_b : STD_LOGIC_VECTOR (3 downto 0);
    signal redist36_cmp_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist36_notEnable_a : STD_LOGIC_VECTOR (0 downto 0);
    signal redist36_notEnable_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist36_nor_a : STD_LOGIC_VECTOR (0 downto 0);
    signal redist36_nor_b : STD_LOGIC_VECTOR (0 downto 0);
    signal redist36_nor_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist36_enaAnd_a : STD_LOGIC_VECTOR (0 downto 0);
    signal redist36_enaAnd_b : STD_LOGIC_VECTOR (0 downto 0);
    signal redist36_enaAnd_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expX_uid9_fpDivTest_in : STD_LOGIC_VECTOR (31 downto 0);
    signal expX_uid9_fpDivTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal fracX_uid10_fpDivTest_in : STD_LOGIC_VECTOR (31 downto 0);
    signal fracX_uid10_fpDivTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal signX_uid11_fpDivTest_in : STD_LOGIC_VECTOR (31 downto 0);
    signal signX_uid11_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal expY_uid12_fpDivTest_in : STD_LOGIC_VECTOR (31 downto 0);
    signal expY_uid12_fpDivTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal fracY_uid13_fpDivTest_in : STD_LOGIC_VECTOR (31 downto 0);
    signal fracY_uid13_fpDivTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal signY_uid14_fpDivTest_in : STD_LOGIC_VECTOR (31 downto 0);
    signal signY_uid14_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal yPE_uid52_fpDivTest_in : STD_LOGIC_VECTOR (31 downto 0);
    signal yPE_uid52_fpDivTest_b : STD_LOGIC_VECTOR (13 downto 0);
    signal oFracXZ4_uid61_fpDivTest_q : STD_LOGIC_VECTOR (27 downto 0);
    signal fracPostRndF_uid79_fpDivTest_in : STD_LOGIC_VECTOR (24 downto 0);
    signal fracPostRndF_uid79_fpDivTest_b : STD_LOGIC_VECTOR (23 downto 0);
    signal expPostRndFR_uid81_fpDivTest_in : STD_LOGIC_VECTOR (32 downto 0);
    signal expPostRndFR_uid81_fpDivTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal expRExt_uid114_fpDivTest_in : STD_LOGIC_VECTOR (35 downto 0);
    signal expRExt_uid114_fpDivTest_b : STD_LOGIC_VECTOR (10 downto 0);
    signal fracPostRndFPostUlp_uid106_fpDivTest_in : STD_LOGIC_VECTOR (22 downto 0);
    signal fracPostRndFPostUlp_uid106_fpDivTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal ovfIncRnd_uid109_fpDivTest_in : STD_LOGIC_VECTOR (23 downto 0);
    signal ovfIncRnd_uid109_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal divR_uid144_fpDivTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal s1_uid165_invPolyEval_q : STD_LOGIC_VECTOR (23 downto 0);
    signal os_uid148_invTables_q : STD_LOGIC_VECTOR (31 downto 0);
    signal os_uid152_invTables_q : STD_LOGIC_VECTOR (21 downto 0);
    signal qDivProdNorm_uid90_fpDivTest_in : STD_LOGIC_VECTOR (48 downto 0);
    signal qDivProdNorm_uid90_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal qDivProdFracHigh_uid91_fpDivTest_in : STD_LOGIC_VECTOR (47 downto 0);
    signal qDivProdFracHigh_uid91_fpDivTest_b : STD_LOGIC_VECTOR (23 downto 0);
    signal qDivProdFracLow_uid92_fpDivTest_in : STD_LOGIC_VECTOR (46 downto 0);
    signal qDivProdFracLow_uid92_fpDivTest_b : STD_LOGIC_VECTOR (23 downto 0);
    signal osig_uid174_divValPreNorm_uid59_fpDivTest_in : STD_LOGIC_VECTOR (50 downto 0);
    signal osig_uid174_divValPreNorm_uid59_fpDivTest_b : STD_LOGIC_VECTOR (27 downto 0);
    signal osig_uid177_pT1_uid161_invPolyEval_in : STD_LOGIC_VECTOR (25 downto 0);
    signal osig_uid177_pT1_uid161_invPolyEval_b : STD_LOGIC_VECTOR (13 downto 0);
    signal osig_uid180_pT2_uid167_invPolyEval_in : STD_LOGIC_VECTOR (37 downto 0);
    signal osig_uid180_pT2_uid167_invPolyEval_b : STD_LOGIC_VECTOR (24 downto 0);
    signal s2_uid171_invPolyEval_q : STD_LOGIC_VECTOR (34 downto 0);
    signal fracRPreExc_uid107_fpDivTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal fracRPreExc_uid107_fpDivTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal fracPostRndF_uid80_fpDivTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal fracPostRndF_uid80_fpDivTest_q : STD_LOGIC_VECTOR (23 downto 0);
    signal yT1_uid160_invPolyEval_in : STD_LOGIC_VECTOR (13 downto 0);
    signal yT1_uid160_invPolyEval_b : STD_LOGIC_VECTOR (12 downto 0);
    signal qDivProdLTX_opB_uid100_fpDivTest_q : STD_LOGIC_VECTOR (30 downto 0);
    signal expFracPostRndInc_uid110_fpDivTest_a : STD_LOGIC_VECTOR (8 downto 0);
    signal expFracPostRndInc_uid110_fpDivTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal expFracPostRndInc_uid110_fpDivTest_o : STD_LOGIC_VECTOR (8 downto 0);
    signal expFracPostRndInc_uid110_fpDivTest_q : STD_LOGIC_VECTOR (8 downto 0);
    signal qDivProdLTX_opA_uid98_fpDivTest_in : STD_LOGIC_VECTOR (7 downto 0);
    signal qDivProdLTX_opA_uid98_fpDivTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal concExc_uid132_fpDivTest_q : STD_LOGIC_VECTOR (2 downto 0);
    signal yAddr_uid51_fpDivTest_in : STD_LOGIC_VECTOR (22 downto 0);
    signal yAddr_uid51_fpDivTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal divValPreNormYPow2Exc_uid63_fpDivTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal divValPreNormYPow2Exc_uid63_fpDivTest_q : STD_LOGIC_VECTOR (27 downto 0);
    signal qDivProdFrac_uid93_fpDivTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal qDivProdFrac_uid93_fpDivTest_q : STD_LOGIC_VECTOR (23 downto 0);
    signal lowRangeB_uid162_invPolyEval_in : STD_LOGIC_VECTOR (0 downto 0);
    signal lowRangeB_uid162_invPolyEval_b : STD_LOGIC_VECTOR (0 downto 0);
    signal highBBits_uid163_invPolyEval_in : STD_LOGIC_VECTOR (13 downto 0);
    signal highBBits_uid163_invPolyEval_b : STD_LOGIC_VECTOR (12 downto 0);
    signal lowRangeB_uid168_invPolyEval_in : STD_LOGIC_VECTOR (1 downto 0);
    signal lowRangeB_uid168_invPolyEval_b : STD_LOGIC_VECTOR (1 downto 0);
    signal highBBits_uid169_invPolyEval_in : STD_LOGIC_VECTOR (24 downto 0);
    signal highBBits_uid169_invPolyEval_b : STD_LOGIC_VECTOR (22 downto 0);
    signal invY_uid54_fpDivTest_in : STD_LOGIC_VECTOR (31 downto 0);
    signal invY_uid54_fpDivTest_b : STD_LOGIC_VECTOR (26 downto 0);
    signal invYO_uid55_fpDivTest_in : STD_LOGIC_VECTOR (32 downto 0);
    signal invYO_uid55_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal lOAdded_uid84_fpDivTest_q : STD_LOGIC_VECTOR (24 downto 0);
    signal betweenFPwF_uid102_fpDivTest_in : STD_LOGIC_VECTOR (0 downto 0);
    signal betweenFPwF_uid102_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal fracPostRndFT_uid104_fpDivTest_in : STD_LOGIC_VECTOR (23 downto 0);
    signal fracPostRndFT_uid104_fpDivTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal expFracPostRndR_uid111_fpDivTest_in : STD_LOGIC_VECTOR (7 downto 0);
    signal expFracPostRndR_uid111_fpDivTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal qDivProdLTX_opA_uid99_fpDivTest_q : STD_LOGIC_VECTOR (30 downto 0);
    signal norm_uid64_fpDivTest_in : STD_LOGIC_VECTOR (27 downto 0);
    signal norm_uid64_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal divValPreNormHigh_uid65_fpDivTest_in : STD_LOGIC_VECTOR (26 downto 0);
    signal divValPreNormHigh_uid65_fpDivTest_b : STD_LOGIC_VECTOR (24 downto 0);
    signal divValPreNormLow_uid66_fpDivTest_in : STD_LOGIC_VECTOR (25 downto 0);
    signal divValPreNormLow_uid66_fpDivTest_b : STD_LOGIC_VECTOR (24 downto 0);
    signal qDivProdFracWF_uid97_fpDivTest_in : STD_LOGIC_VECTOR (23 downto 0);
    signal qDivProdFracWF_uid97_fpDivTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal normFracRnd_uid67_fpDivTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal normFracRnd_uid67_fpDivTest_q : STD_LOGIC_VECTOR (24 downto 0);
    signal expFracRnd_uid68_fpDivTest_q : STD_LOGIC_VECTOR (34 downto 0);

begin


    -- VCC(CONSTANT,1)
    VCC_q <= "1";

    -- redist29_notEnable(LOGICAL,248)
    redist29_notEnable_a <= VCC_q;
    redist29_notEnable_q <= not (redist29_notEnable_a);

    -- redist29_nor(LOGICAL,249)
    redist29_nor_a <= redist29_notEnable_q;
    redist29_nor_b <= redist29_sticky_ena_q;
    redist29_nor_q <= not (redist29_nor_a or redist29_nor_b);

    -- redist29_mem_top(CONSTANT,245)
    redist29_mem_top_q <= "0111";

    -- redist29_cmp(LOGICAL,246)
    redist29_cmp_a <= redist29_mem_top_q;
    redist29_cmp_b <= STD_LOGIC_VECTOR("0" & redist29_rdcnt_q);
    redist29_cmp_q <= "1" WHEN redist29_cmp_a = redist29_cmp_b ELSE "0";

    -- redist29_cmpReg(REG,247)
    redist29_cmpReg: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist29_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist29_cmpReg_q <= STD_LOGIC_VECTOR(redist29_cmp_q);
        END IF;
    END PROCESS;

    -- redist29_sticky_ena(REG,250)
    redist29_sticky_ena: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist29_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist29_nor_q = "1") THEN
                redist29_sticky_ena_q <= STD_LOGIC_VECTOR(redist29_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- redist29_enaAnd(LOGICAL,251)
    redist29_enaAnd_a <= redist29_sticky_ena_q;
    redist29_enaAnd_b <= VCC_q;
    redist29_enaAnd_q <= redist29_enaAnd_a and redist29_enaAnd_b;

    -- redist29_rdcnt(COUNTER,243)
    -- every=1, low=0, high=7, step=1, init=1
    redist29_rdcnt: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist29_rdcnt_i <= TO_UNSIGNED(1, 3);
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist29_rdcnt_i <= redist29_rdcnt_i + 1;
        END IF;
    END PROCESS;
    redist29_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(redist29_rdcnt_i, 3)));

    -- xIn(GPIN,3)@0

    -- fracY_uid13_fpDivTest(BITSELECT,12)@0
    fracY_uid13_fpDivTest_in <= b;
    fracY_uid13_fpDivTest_b <= fracY_uid13_fpDivTest_in(22 downto 0);

    -- redist29_wraddr(REG,244)
    redist29_wraddr: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist29_wraddr_q <= "000";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist29_wraddr_q <= STD_LOGIC_VECTOR(redist29_rdcnt_q);
        END IF;
    END PROCESS;

    -- redist29_mem(DUALMEM,242)
    redist29_mem_ia <= STD_LOGIC_VECTOR(fracY_uid13_fpDivTest_b);
    redist29_mem_aa <= redist29_wraddr_q;
    redist29_mem_ab <= redist29_rdcnt_q;
    redist29_mem_reset0 <= areset;
    redist29_mem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "MLAB",
        operation_mode => "DUAL_PORT",
        width_a => 23,
        widthad_a => 3,
        numwords_a => 8,
        width_b => 23,
        widthad_b => 3,
        numwords_b => 8,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK1",
        outdata_aclr_b => "CLEAR1",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "TRUE",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken1 => redist29_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => redist29_mem_reset0,
        clock1 => clk,
        address_a => redist29_mem_aa,
        data_a => redist29_mem_ia,
        wren_a => VCC_q(0),
        address_b => redist29_mem_ab,
        q_b => redist29_mem_iq
    );
    redist29_mem_q <= redist29_mem_iq(22 downto 0);

    -- redist29_outputreg(DELAY,241)
    redist29_outputreg : dspba_delay
    GENERIC MAP ( width => 23, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist29_mem_q, xout => redist29_outputreg_q, clk => clk, aclr => areset );

    -- redist30(DELAY,220)
    redist30 : dspba_delay
    GENERIC MAP ( width => 23, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist29_outputreg_q, xout => redist30_q, clk => clk, aclr => areset );

    -- paddingY_uid15_fpDivTest(CONSTANT,14)
    paddingY_uid15_fpDivTest_q <= "00000000000000000000000";

    -- fracXIsZero_uid39_fpDivTest(LOGICAL,38)@13
    fracXIsZero_uid39_fpDivTest_a <= paddingY_uid15_fpDivTest_q;
    fracXIsZero_uid39_fpDivTest_b <= redist30_q;
    fracXIsZero_uid39_fpDivTest_q_i <= "1" WHEN fracXIsZero_uid39_fpDivTest_a = fracXIsZero_uid39_fpDivTest_b ELSE "0";
    fracXIsZero_uid39_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid39_fpDivTest_q_i, xout => fracXIsZero_uid39_fpDivTest_q, clk => clk, aclr => areset );

    -- cstAllOWE_uid18_fpDivTest(CONSTANT,17)
    cstAllOWE_uid18_fpDivTest_q <= "11111111";

    -- redist31_notEnable(LOGICAL,259)
    redist31_notEnable_a <= VCC_q;
    redist31_notEnable_q <= not (redist31_notEnable_a);

    -- redist31_nor(LOGICAL,260)
    redist31_nor_a <= redist31_notEnable_q;
    redist31_nor_b <= redist31_sticky_ena_q;
    redist31_nor_q <= not (redist31_nor_a or redist31_nor_b);

    -- redist31_mem_top(CONSTANT,256)
    redist31_mem_top_q <= "0111";

    -- redist31_cmp(LOGICAL,257)
    redist31_cmp_a <= redist31_mem_top_q;
    redist31_cmp_b <= STD_LOGIC_VECTOR("0" & redist31_rdcnt_q);
    redist31_cmp_q <= "1" WHEN redist31_cmp_a = redist31_cmp_b ELSE "0";

    -- redist31_cmpReg(REG,258)
    redist31_cmpReg: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist31_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist31_cmpReg_q <= STD_LOGIC_VECTOR(redist31_cmp_q);
        END IF;
    END PROCESS;

    -- redist31_sticky_ena(REG,261)
    redist31_sticky_ena: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist31_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist31_nor_q = "1") THEN
                redist31_sticky_ena_q <= STD_LOGIC_VECTOR(redist31_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- redist31_enaAnd(LOGICAL,262)
    redist31_enaAnd_a <= redist31_sticky_ena_q;
    redist31_enaAnd_b <= VCC_q;
    redist31_enaAnd_q <= redist31_enaAnd_a and redist31_enaAnd_b;

    -- redist31_rdcnt(COUNTER,254)
    -- every=1, low=0, high=7, step=1, init=1
    redist31_rdcnt: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist31_rdcnt_i <= TO_UNSIGNED(1, 3);
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist31_rdcnt_i <= redist31_rdcnt_i + 1;
        END IF;
    END PROCESS;
    redist31_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(redist31_rdcnt_i, 3)));

    -- expY_uid12_fpDivTest(BITSELECT,11)@0
    expY_uid12_fpDivTest_in <= b;
    expY_uid12_fpDivTest_b <= expY_uid12_fpDivTest_in(30 downto 23);

    -- redist31_wraddr(REG,255)
    redist31_wraddr: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist31_wraddr_q <= "000";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist31_wraddr_q <= STD_LOGIC_VECTOR(redist31_rdcnt_q);
        END IF;
    END PROCESS;

    -- redist31_mem(DUALMEM,253)
    redist31_mem_ia <= STD_LOGIC_VECTOR(expY_uid12_fpDivTest_b);
    redist31_mem_aa <= redist31_wraddr_q;
    redist31_mem_ab <= redist31_rdcnt_q;
    redist31_mem_reset0 <= areset;
    redist31_mem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "MLAB",
        operation_mode => "DUAL_PORT",
        width_a => 8,
        widthad_a => 3,
        numwords_a => 8,
        width_b => 8,
        widthad_b => 3,
        numwords_b => 8,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK1",
        outdata_aclr_b => "CLEAR1",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "TRUE",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken1 => redist31_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => redist31_mem_reset0,
        clock1 => clk,
        address_a => redist31_mem_aa,
        data_a => redist31_mem_ia,
        wren_a => VCC_q(0),
        address_b => redist31_mem_ab,
        q_b => redist31_mem_iq
    );
    redist31_mem_q <= redist31_mem_iq(7 downto 0);

    -- redist31_outputreg(DELAY,252)
    redist31_outputreg : dspba_delay
    GENERIC MAP ( width => 8, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist31_mem_q, xout => redist31_outputreg_q, clk => clk, aclr => areset );

    -- redist32(DELAY,222)
    redist32 : dspba_delay
    GENERIC MAP ( width => 8, depth => 4, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist31_outputreg_q, xout => redist32_q, clk => clk, aclr => areset );

    -- expXIsMax_uid38_fpDivTest(LOGICAL,37)@14
    expXIsMax_uid38_fpDivTest_a <= redist32_q;
    expXIsMax_uid38_fpDivTest_b <= cstAllOWE_uid18_fpDivTest_q;
    expXIsMax_uid38_fpDivTest_q <= "1" WHEN expXIsMax_uid38_fpDivTest_a = expXIsMax_uid38_fpDivTest_b ELSE "0";

    -- excI_y_uid41_fpDivTest(LOGICAL,40)@14
    excI_y_uid41_fpDivTest_a <= expXIsMax_uid38_fpDivTest_q;
    excI_y_uid41_fpDivTest_b <= fracXIsZero_uid39_fpDivTest_q;
    excI_y_uid41_fpDivTest_q <= excI_y_uid41_fpDivTest_a and excI_y_uid41_fpDivTest_b;

    -- redist33_notEnable(LOGICAL,270)
    redist33_notEnable_a <= VCC_q;
    redist33_notEnable_q <= not (redist33_notEnable_a);

    -- redist33_nor(LOGICAL,271)
    redist33_nor_a <= redist33_notEnable_q;
    redist33_nor_b <= redist33_sticky_ena_q;
    redist33_nor_q <= not (redist33_nor_a or redist33_nor_b);

    -- redist33_mem_top(CONSTANT,267)
    redist33_mem_top_q <= "0110";

    -- redist33_cmp(LOGICAL,268)
    redist33_cmp_a <= redist33_mem_top_q;
    redist33_cmp_b <= STD_LOGIC_VECTOR("0" & redist33_rdcnt_q);
    redist33_cmp_q <= "1" WHEN redist33_cmp_a = redist33_cmp_b ELSE "0";

    -- redist33_cmpReg(REG,269)
    redist33_cmpReg: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist33_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist33_cmpReg_q <= STD_LOGIC_VECTOR(redist33_cmp_q);
        END IF;
    END PROCESS;

    -- redist33_sticky_ena(REG,272)
    redist33_sticky_ena: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist33_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist33_nor_q = "1") THEN
                redist33_sticky_ena_q <= STD_LOGIC_VECTOR(redist33_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- redist33_enaAnd(LOGICAL,273)
    redist33_enaAnd_a <= redist33_sticky_ena_q;
    redist33_enaAnd_b <= VCC_q;
    redist33_enaAnd_q <= redist33_enaAnd_a and redist33_enaAnd_b;

    -- redist33_rdcnt(COUNTER,265)
    -- every=1, low=0, high=6, step=1, init=1
    redist33_rdcnt: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist33_rdcnt_i <= TO_UNSIGNED(1, 3);
            redist33_rdcnt_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist33_rdcnt_i = TO_UNSIGNED(5, 3)) THEN
                redist33_rdcnt_eq <= '1';
            ELSE
                redist33_rdcnt_eq <= '0';
            END IF;
            IF (redist33_rdcnt_eq = '1') THEN
                redist33_rdcnt_i <= redist33_rdcnt_i - 6;
            ELSE
                redist33_rdcnt_i <= redist33_rdcnt_i + 1;
            END IF;
        END IF;
    END PROCESS;
    redist33_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(redist33_rdcnt_i, 3)));

    -- fracX_uid10_fpDivTest(BITSELECT,9)@0
    fracX_uid10_fpDivTest_in <= a;
    fracX_uid10_fpDivTest_b <= fracX_uid10_fpDivTest_in(22 downto 0);

    -- redist33_wraddr(REG,266)
    redist33_wraddr: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist33_wraddr_q <= "000";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist33_wraddr_q <= STD_LOGIC_VECTOR(redist33_rdcnt_q);
        END IF;
    END PROCESS;

    -- redist33_mem(DUALMEM,264)
    redist33_mem_ia <= STD_LOGIC_VECTOR(fracX_uid10_fpDivTest_b);
    redist33_mem_aa <= redist33_wraddr_q;
    redist33_mem_ab <= redist33_rdcnt_q;
    redist33_mem_reset0 <= areset;
    redist33_mem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "MLAB",
        operation_mode => "DUAL_PORT",
        width_a => 23,
        widthad_a => 3,
        numwords_a => 7,
        width_b => 23,
        widthad_b => 3,
        numwords_b => 7,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK1",
        outdata_aclr_b => "CLEAR1",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "TRUE",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken1 => redist33_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => redist33_mem_reset0,
        clock1 => clk,
        address_a => redist33_mem_aa,
        data_a => redist33_mem_ia,
        wren_a => VCC_q(0),
        address_b => redist33_mem_ab,
        q_b => redist33_mem_iq
    );
    redist33_mem_q <= redist33_mem_iq(22 downto 0);

    -- redist33_outputreg(DELAY,263)
    redist33_outputreg : dspba_delay
    GENERIC MAP ( width => 23, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist33_mem_q, xout => redist33_outputreg_q, clk => clk, aclr => areset );

    -- redist34_inputreg(DELAY,274)
    redist34_inputreg : dspba_delay
    GENERIC MAP ( width => 23, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist33_outputreg_q, xout => redist34_inputreg_q, clk => clk, aclr => areset );

    -- redist34(DELAY,224)
    redist34 : dspba_delay
    GENERIC MAP ( width => 23, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist34_inputreg_q, xout => redist34_q, clk => clk, aclr => areset );

    -- fracXIsZero_uid25_fpDivTest(LOGICAL,24)@13
    fracXIsZero_uid25_fpDivTest_a <= paddingY_uid15_fpDivTest_q;
    fracXIsZero_uid25_fpDivTest_b <= redist34_q;
    fracXIsZero_uid25_fpDivTest_q_i <= "1" WHEN fracXIsZero_uid25_fpDivTest_a = fracXIsZero_uid25_fpDivTest_b ELSE "0";
    fracXIsZero_uid25_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid25_fpDivTest_q_i, xout => fracXIsZero_uid25_fpDivTest_q, clk => clk, aclr => areset );

    -- redist36_notEnable(LOGICAL,282)
    redist36_notEnable_a <= VCC_q;
    redist36_notEnable_q <= not (redist36_notEnable_a);

    -- redist36_nor(LOGICAL,283)
    redist36_nor_a <= redist36_notEnable_q;
    redist36_nor_b <= redist36_sticky_ena_q;
    redist36_nor_q <= not (redist36_nor_a or redist36_nor_b);

    -- redist36_mem_top(CONSTANT,279)
    redist36_mem_top_q <= "0111";

    -- redist36_cmp(LOGICAL,280)
    redist36_cmp_a <= redist36_mem_top_q;
    redist36_cmp_b <= STD_LOGIC_VECTOR("0" & redist36_rdcnt_q);
    redist36_cmp_q <= "1" WHEN redist36_cmp_a = redist36_cmp_b ELSE "0";

    -- redist36_cmpReg(REG,281)
    redist36_cmpReg: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist36_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist36_cmpReg_q <= STD_LOGIC_VECTOR(redist36_cmp_q);
        END IF;
    END PROCESS;

    -- redist36_sticky_ena(REG,284)
    redist36_sticky_ena: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist36_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist36_nor_q = "1") THEN
                redist36_sticky_ena_q <= STD_LOGIC_VECTOR(redist36_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- redist36_enaAnd(LOGICAL,285)
    redist36_enaAnd_a <= redist36_sticky_ena_q;
    redist36_enaAnd_b <= VCC_q;
    redist36_enaAnd_q <= redist36_enaAnd_a and redist36_enaAnd_b;

    -- redist36_rdcnt(COUNTER,277)
    -- every=1, low=0, high=7, step=1, init=1
    redist36_rdcnt: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist36_rdcnt_i <= TO_UNSIGNED(1, 3);
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist36_rdcnt_i <= redist36_rdcnt_i + 1;
        END IF;
    END PROCESS;
    redist36_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(redist36_rdcnt_i, 3)));

    -- expX_uid9_fpDivTest(BITSELECT,8)@0
    expX_uid9_fpDivTest_in <= a;
    expX_uid9_fpDivTest_b <= expX_uid9_fpDivTest_in(30 downto 23);

    -- redist36_wraddr(REG,278)
    redist36_wraddr: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist36_wraddr_q <= "000";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist36_wraddr_q <= STD_LOGIC_VECTOR(redist36_rdcnt_q);
        END IF;
    END PROCESS;

    -- redist36_mem(DUALMEM,276)
    redist36_mem_ia <= STD_LOGIC_VECTOR(expX_uid9_fpDivTest_b);
    redist36_mem_aa <= redist36_wraddr_q;
    redist36_mem_ab <= redist36_rdcnt_q;
    redist36_mem_reset0 <= areset;
    redist36_mem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "MLAB",
        operation_mode => "DUAL_PORT",
        width_a => 8,
        widthad_a => 3,
        numwords_a => 8,
        width_b => 8,
        widthad_b => 3,
        numwords_b => 8,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK1",
        outdata_aclr_b => "CLEAR1",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "TRUE",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken1 => redist36_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => redist36_mem_reset0,
        clock1 => clk,
        address_a => redist36_mem_aa,
        data_a => redist36_mem_ia,
        wren_a => VCC_q(0),
        address_b => redist36_mem_ab,
        q_b => redist36_mem_iq
    );
    redist36_mem_q <= redist36_mem_iq(7 downto 0);

    -- redist36_outputreg(DELAY,275)
    redist36_outputreg : dspba_delay
    GENERIC MAP ( width => 8, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist36_mem_q, xout => redist36_outputreg_q, clk => clk, aclr => areset );

    -- redist37(DELAY,227)
    redist37 : dspba_delay
    GENERIC MAP ( width => 8, depth => 4, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist36_outputreg_q, xout => redist37_q, clk => clk, aclr => areset );

    -- expXIsMax_uid24_fpDivTest(LOGICAL,23)@14
    expXIsMax_uid24_fpDivTest_a <= redist37_q;
    expXIsMax_uid24_fpDivTest_b <= cstAllOWE_uid18_fpDivTest_q;
    expXIsMax_uid24_fpDivTest_q <= "1" WHEN expXIsMax_uid24_fpDivTest_a = expXIsMax_uid24_fpDivTest_b ELSE "0";

    -- excI_x_uid27_fpDivTest(LOGICAL,26)@14
    excI_x_uid27_fpDivTest_a <= expXIsMax_uid24_fpDivTest_q;
    excI_x_uid27_fpDivTest_b <= fracXIsZero_uid25_fpDivTest_q;
    excI_x_uid27_fpDivTest_q <= excI_x_uid27_fpDivTest_a and excI_x_uid27_fpDivTest_b;

    -- excXIYI_uid130_fpDivTest(LOGICAL,129)@14
    excXIYI_uid130_fpDivTest_a <= excI_x_uid27_fpDivTest_q;
    excXIYI_uid130_fpDivTest_b <= excI_y_uid41_fpDivTest_q;
    excXIYI_uid130_fpDivTest_q <= excXIYI_uid130_fpDivTest_a and excXIYI_uid130_fpDivTest_b;

    -- fracXIsNotZero_uid40_fpDivTest(LOGICAL,39)@14
    fracXIsNotZero_uid40_fpDivTest_a <= fracXIsZero_uid39_fpDivTest_q;
    fracXIsNotZero_uid40_fpDivTest_q <= not (fracXIsNotZero_uid40_fpDivTest_a);

    -- excN_y_uid42_fpDivTest(LOGICAL,41)@14
    excN_y_uid42_fpDivTest_a <= expXIsMax_uid38_fpDivTest_q;
    excN_y_uid42_fpDivTest_b <= fracXIsNotZero_uid40_fpDivTest_q;
    excN_y_uid42_fpDivTest_q <= excN_y_uid42_fpDivTest_a and excN_y_uid42_fpDivTest_b;

    -- fracXIsNotZero_uid26_fpDivTest(LOGICAL,25)@14
    fracXIsNotZero_uid26_fpDivTest_a <= fracXIsZero_uid25_fpDivTest_q;
    fracXIsNotZero_uid26_fpDivTest_q <= not (fracXIsNotZero_uid26_fpDivTest_a);

    -- excN_x_uid28_fpDivTest(LOGICAL,27)@14
    excN_x_uid28_fpDivTest_a <= expXIsMax_uid24_fpDivTest_q;
    excN_x_uid28_fpDivTest_b <= fracXIsNotZero_uid26_fpDivTest_q;
    excN_x_uid28_fpDivTest_q <= excN_x_uid28_fpDivTest_a and excN_x_uid28_fpDivTest_b;

    -- cstAllZWE_uid20_fpDivTest(CONSTANT,19)
    cstAllZWE_uid20_fpDivTest_q <= "00000000";

    -- excZ_y_uid37_fpDivTest(LOGICAL,36)@14
    excZ_y_uid37_fpDivTest_a <= redist32_q;
    excZ_y_uid37_fpDivTest_b <= cstAllZWE_uid20_fpDivTest_q;
    excZ_y_uid37_fpDivTest_q <= "1" WHEN excZ_y_uid37_fpDivTest_a = excZ_y_uid37_fpDivTest_b ELSE "0";

    -- excZ_x_uid23_fpDivTest(LOGICAL,22)@14
    excZ_x_uid23_fpDivTest_a <= redist37_q;
    excZ_x_uid23_fpDivTest_b <= cstAllZWE_uid20_fpDivTest_q;
    excZ_x_uid23_fpDivTest_q <= "1" WHEN excZ_x_uid23_fpDivTest_a = excZ_x_uid23_fpDivTest_b ELSE "0";

    -- excXZYZ_uid129_fpDivTest(LOGICAL,128)@14
    excXZYZ_uid129_fpDivTest_a <= excZ_x_uid23_fpDivTest_q;
    excXZYZ_uid129_fpDivTest_b <= excZ_y_uid37_fpDivTest_q;
    excXZYZ_uid129_fpDivTest_q <= excXZYZ_uid129_fpDivTest_a and excXZYZ_uid129_fpDivTest_b;

    -- excRNaN_uid131_fpDivTest(LOGICAL,130)@14
    excRNaN_uid131_fpDivTest_a <= excXZYZ_uid129_fpDivTest_q;
    excRNaN_uid131_fpDivTest_b <= excN_x_uid28_fpDivTest_q;
    excRNaN_uid131_fpDivTest_c <= excN_y_uid42_fpDivTest_q;
    excRNaN_uid131_fpDivTest_d <= excXIYI_uid130_fpDivTest_q;
    excRNaN_uid131_fpDivTest_q <= excRNaN_uid131_fpDivTest_a or excRNaN_uid131_fpDivTest_b or excRNaN_uid131_fpDivTest_c or excRNaN_uid131_fpDivTest_d;

    -- invExcRNaN_uid142_fpDivTest(LOGICAL,141)@14
    invExcRNaN_uid142_fpDivTest_a <= excRNaN_uid131_fpDivTest_q;
    invExcRNaN_uid142_fpDivTest_q <= not (invExcRNaN_uid142_fpDivTest_a);

    -- signY_uid14_fpDivTest(BITSELECT,13)@0
    signY_uid14_fpDivTest_in <= STD_LOGIC_VECTOR(b);
    signY_uid14_fpDivTest_b <= signY_uid14_fpDivTest_in(31 downto 31);

    -- signX_uid11_fpDivTest(BITSELECT,10)@0
    signX_uid11_fpDivTest_in <= STD_LOGIC_VECTOR(a);
    signX_uid11_fpDivTest_b <= signX_uid11_fpDivTest_in(31 downto 31);

    -- signR_uid46_fpDivTest(LOGICAL,45)@0
    signR_uid46_fpDivTest_a <= signX_uid11_fpDivTest_b;
    signR_uid46_fpDivTest_b <= signY_uid14_fpDivTest_b;
    signR_uid46_fpDivTest_q_i <= signR_uid46_fpDivTest_a xor signR_uid46_fpDivTest_b;
    signR_uid46_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => signR_uid46_fpDivTest_q_i, xout => signR_uid46_fpDivTest_q, clk => clk, aclr => areset );

    -- redist28(DELAY,218)
    redist28 : dspba_delay
    GENERIC MAP ( width => 1, depth => 13, reset_kind => "ASYNC" )
    PORT MAP ( xin => signR_uid46_fpDivTest_q, xout => redist28_q, clk => clk, aclr => areset );

    -- sRPostExc_uid143_fpDivTest(LOGICAL,142)@14
    sRPostExc_uid143_fpDivTest_a <= redist28_q;
    sRPostExc_uid143_fpDivTest_b <= invExcRNaN_uid142_fpDivTest_q;
    sRPostExc_uid143_fpDivTest_q_i <= sRPostExc_uid143_fpDivTest_a and sRPostExc_uid143_fpDivTest_b;
    sRPostExc_uid143_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => sRPostExc_uid143_fpDivTest_q_i, xout => sRPostExc_uid143_fpDivTest_q, clk => clk, aclr => areset );

    -- redist4(DELAY,194)
    redist4 : dspba_delay
    GENERIC MAP ( width => 1, depth => 5, reset_kind => "ASYNC" )
    PORT MAP ( xin => sRPostExc_uid143_fpDivTest_q, xout => redist4_q, clk => clk, aclr => areset );

    -- GND(CONSTANT,0)
    GND_q <= "0";

    -- fracXExt_uid77_fpDivTest(BITJOIN,76)@13
    fracXExt_uid77_fpDivTest_q <= redist34_q & GND_q;

    -- lOAdded_uid57_fpDivTest(BITJOIN,56)@9
    lOAdded_uid57_fpDivTest_q <= VCC_q & redist33_outputreg_q;

    -- redist20(DELAY,210)
    redist20 : dspba_delay
    GENERIC MAP ( width => 24, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => lOAdded_uid57_fpDivTest_q, xout => redist20_q, clk => clk, aclr => areset );

    -- z4_uid60_fpDivTest(CONSTANT,59)
    z4_uid60_fpDivTest_q <= "0000";

    -- oFracXZ4_uid61_fpDivTest(BITJOIN,60)@11
    oFracXZ4_uid61_fpDivTest_q <= redist20_q & z4_uid60_fpDivTest_q;

    -- yAddr_uid51_fpDivTest(BITSELECT,50)@0
    yAddr_uid51_fpDivTest_in <= fracY_uid13_fpDivTest_b;
    yAddr_uid51_fpDivTest_b <= yAddr_uid51_fpDivTest_in(22 downto 14);

    -- memoryC2_uid154_invTables_lutmem(DUALMEM,185)@0
    memoryC2_uid154_invTables_lutmem_aa <= yAddr_uid51_fpDivTest_b;
    memoryC2_uid154_invTables_lutmem_reset0 <= areset;
    memoryC2_uid154_invTables_lutmem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "M10K",
        operation_mode => "ROM",
        width_a => 13,
        widthad_a => 9,
        numwords_a => 512,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "fpdiv14_0002_memoryC2_uid154_invTables_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken0 => VCC_q(0),
        aclr0 => memoryC2_uid154_invTables_lutmem_reset0,
        clock0 => clk,
        address_a => memoryC2_uid154_invTables_lutmem_aa,
        q_a => memoryC2_uid154_invTables_lutmem_ir
    );
    memoryC2_uid154_invTables_lutmem_r <= memoryC2_uid154_invTables_lutmem_ir(12 downto 0);

    -- yPE_uid52_fpDivTest(BITSELECT,51)@0
    yPE_uid52_fpDivTest_in <= b;
    yPE_uid52_fpDivTest_b <= yPE_uid52_fpDivTest_in(13 downto 0);

    -- redist24(DELAY,214)
    redist24 : dspba_delay
    GENERIC MAP ( width => 14, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => yPE_uid52_fpDivTest_b, xout => redist24_q, clk => clk, aclr => areset );

    -- yT1_uid160_invPolyEval(BITSELECT,159)@2
    yT1_uid160_invPolyEval_in <= redist24_q;
    yT1_uid160_invPolyEval_b <= yT1_uid160_invPolyEval_in(13 downto 1);

    -- prodXY_uid176_pT1_uid161_invPolyEval_cma(CHAINMULTADD,188)@2
    prodXY_uid176_pT1_uid161_invPolyEval_cma_l(0) <= SIGNED(RESIZE(prodXY_uid176_pT1_uid161_invPolyEval_cma_a0(0),14));
    prodXY_uid176_pT1_uid161_invPolyEval_cma_p(0) <= prodXY_uid176_pT1_uid161_invPolyEval_cma_l(0) * prodXY_uid176_pT1_uid161_invPolyEval_cma_c0(0);
    prodXY_uid176_pT1_uid161_invPolyEval_cma_u(0) <= RESIZE(prodXY_uid176_pT1_uid161_invPolyEval_cma_p(0),27);
    prodXY_uid176_pT1_uid161_invPolyEval_cma_w(0) <= prodXY_uid176_pT1_uid161_invPolyEval_cma_u(0);
    prodXY_uid176_pT1_uid161_invPolyEval_cma_x(0) <= prodXY_uid176_pT1_uid161_invPolyEval_cma_w(0);
    prodXY_uid176_pT1_uid161_invPolyEval_cma_y(0) <= prodXY_uid176_pT1_uid161_invPolyEval_cma_x(0);
    prodXY_uid176_pT1_uid161_invPolyEval_cma_chainmultadd: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            prodXY_uid176_pT1_uid161_invPolyEval_cma_a0 <= (others => (others => '0'));
            prodXY_uid176_pT1_uid161_invPolyEval_cma_c0 <= (others => (others => '0'));
            prodXY_uid176_pT1_uid161_invPolyEval_cma_s <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            prodXY_uid176_pT1_uid161_invPolyEval_cma_a0(0) <= RESIZE(UNSIGNED(yT1_uid160_invPolyEval_b),13);
            prodXY_uid176_pT1_uid161_invPolyEval_cma_c0(0) <= RESIZE(SIGNED(memoryC2_uid154_invTables_lutmem_r),13);
            prodXY_uid176_pT1_uid161_invPolyEval_cma_s(0) <= prodXY_uid176_pT1_uid161_invPolyEval_cma_y(0);
        END IF;
    END PROCESS;
    prodXY_uid176_pT1_uid161_invPolyEval_cma_delay : dspba_delay
    GENERIC MAP ( width => 26, depth => 0, reset_kind => "ASYNC" )
    PORT MAP ( xin => STD_LOGIC_VECTOR(prodXY_uid176_pT1_uid161_invPolyEval_cma_s(0)(25 downto 0)), xout => prodXY_uid176_pT1_uid161_invPolyEval_cma_qq, clk => clk, aclr => areset );
    prodXY_uid176_pT1_uid161_invPolyEval_cma_q <= STD_LOGIC_VECTOR(prodXY_uid176_pT1_uid161_invPolyEval_cma_qq(25 downto 0));

    -- osig_uid177_pT1_uid161_invPolyEval(BITSELECT,176)@4
    osig_uid177_pT1_uid161_invPolyEval_in <= STD_LOGIC_VECTOR(prodXY_uid176_pT1_uid161_invPolyEval_cma_q);
    osig_uid177_pT1_uid161_invPolyEval_b <= osig_uid177_pT1_uid161_invPolyEval_in(25 downto 12);

    -- highBBits_uid163_invPolyEval(BITSELECT,162)@4
    highBBits_uid163_invPolyEval_in <= STD_LOGIC_VECTOR(osig_uid177_pT1_uid161_invPolyEval_b);
    highBBits_uid163_invPolyEval_b <= highBBits_uid163_invPolyEval_in(13 downto 1);

    -- redist26(DELAY,216)
    redist26 : dspba_delay
    GENERIC MAP ( width => 9, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => yAddr_uid51_fpDivTest_b, xout => redist26_q, clk => clk, aclr => areset );

    -- memoryC1_uid151_invTables_lutmem(DUALMEM,184)@2
    memoryC1_uid151_invTables_lutmem_aa <= redist26_q;
    memoryC1_uid151_invTables_lutmem_reset0 <= areset;
    memoryC1_uid151_invTables_lutmem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "M10K",
        operation_mode => "ROM",
        width_a => 2,
        widthad_a => 9,
        numwords_a => 512,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "fpdiv14_0002_memoryC1_uid151_invTables_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken0 => VCC_q(0),
        aclr0 => memoryC1_uid151_invTables_lutmem_reset0,
        clock0 => clk,
        address_a => memoryC1_uid151_invTables_lutmem_aa,
        q_a => memoryC1_uid151_invTables_lutmem_ir
    );
    memoryC1_uid151_invTables_lutmem_r <= memoryC1_uid151_invTables_lutmem_ir(1 downto 0);

    -- memoryC1_uid150_invTables_lutmem(DUALMEM,183)@2
    memoryC1_uid150_invTables_lutmem_aa <= redist26_q;
    memoryC1_uid150_invTables_lutmem_reset0 <= areset;
    memoryC1_uid150_invTables_lutmem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "M10K",
        operation_mode => "ROM",
        width_a => 20,
        widthad_a => 9,
        numwords_a => 512,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "fpdiv14_0002_memoryC1_uid150_invTables_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken0 => VCC_q(0),
        aclr0 => memoryC1_uid150_invTables_lutmem_reset0,
        clock0 => clk,
        address_a => memoryC1_uid150_invTables_lutmem_aa,
        q_a => memoryC1_uid150_invTables_lutmem_ir
    );
    memoryC1_uid150_invTables_lutmem_r <= memoryC1_uid150_invTables_lutmem_ir(19 downto 0);

    -- os_uid152_invTables(BITJOIN,151)@4
    os_uid152_invTables_q <= memoryC1_uid151_invTables_lutmem_r & memoryC1_uid150_invTables_lutmem_r;

    -- s1sumAHighB_uid164_invPolyEval(ADD,163)@4
    s1sumAHighB_uid164_invPolyEval_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((22 downto 22 => os_uid152_invTables_q(21)) & os_uid152_invTables_q));
    s1sumAHighB_uid164_invPolyEval_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((22 downto 13 => highBBits_uid163_invPolyEval_b(12)) & highBBits_uid163_invPolyEval_b));
    s1sumAHighB_uid164_invPolyEval: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            s1sumAHighB_uid164_invPolyEval_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            s1sumAHighB_uid164_invPolyEval_o <= STD_LOGIC_VECTOR(SIGNED(s1sumAHighB_uid164_invPolyEval_a) + SIGNED(s1sumAHighB_uid164_invPolyEval_b));
        END IF;
    END PROCESS;
    s1sumAHighB_uid164_invPolyEval_q <= s1sumAHighB_uid164_invPolyEval_o(22 downto 0);

    -- lowRangeB_uid162_invPolyEval(BITSELECT,161)@4
    lowRangeB_uid162_invPolyEval_in <= osig_uid177_pT1_uid161_invPolyEval_b(0 downto 0);
    lowRangeB_uid162_invPolyEval_b <= lowRangeB_uid162_invPolyEval_in(0 downto 0);

    -- redist2(DELAY,192)
    redist2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => lowRangeB_uid162_invPolyEval_b, xout => redist2_q, clk => clk, aclr => areset );

    -- s1_uid165_invPolyEval(BITJOIN,164)@5
    s1_uid165_invPolyEval_q <= s1sumAHighB_uid164_invPolyEval_q & redist2_q;

    -- redist25(DELAY,215)
    redist25 : dspba_delay
    GENERIC MAP ( width => 14, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist24_q, xout => redist25_q, clk => clk, aclr => areset );

    -- prodXY_uid179_pT2_uid167_invPolyEval_cma(CHAINMULTADD,189)@5
    prodXY_uid179_pT2_uid167_invPolyEval_cma_l(0) <= SIGNED(RESIZE(prodXY_uid179_pT2_uid167_invPolyEval_cma_a0(0),15));
    prodXY_uid179_pT2_uid167_invPolyEval_cma_p(0) <= prodXY_uid179_pT2_uid167_invPolyEval_cma_l(0) * prodXY_uid179_pT2_uid167_invPolyEval_cma_c0(0);
    prodXY_uid179_pT2_uid167_invPolyEval_cma_u(0) <= RESIZE(prodXY_uid179_pT2_uid167_invPolyEval_cma_p(0),39);
    prodXY_uid179_pT2_uid167_invPolyEval_cma_w(0) <= prodXY_uid179_pT2_uid167_invPolyEval_cma_u(0);
    prodXY_uid179_pT2_uid167_invPolyEval_cma_x(0) <= prodXY_uid179_pT2_uid167_invPolyEval_cma_w(0);
    prodXY_uid179_pT2_uid167_invPolyEval_cma_y(0) <= prodXY_uid179_pT2_uid167_invPolyEval_cma_x(0);
    prodXY_uid179_pT2_uid167_invPolyEval_cma_chainmultadd: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            prodXY_uid179_pT2_uid167_invPolyEval_cma_a0 <= (others => (others => '0'));
            prodXY_uid179_pT2_uid167_invPolyEval_cma_c0 <= (others => (others => '0'));
            prodXY_uid179_pT2_uid167_invPolyEval_cma_s <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            prodXY_uid179_pT2_uid167_invPolyEval_cma_a0(0) <= RESIZE(UNSIGNED(redist25_q),14);
            prodXY_uid179_pT2_uid167_invPolyEval_cma_c0(0) <= RESIZE(SIGNED(s1_uid165_invPolyEval_q),24);
            prodXY_uid179_pT2_uid167_invPolyEval_cma_s(0) <= prodXY_uid179_pT2_uid167_invPolyEval_cma_y(0);
        END IF;
    END PROCESS;
    prodXY_uid179_pT2_uid167_invPolyEval_cma_delay : dspba_delay
    GENERIC MAP ( width => 38, depth => 0, reset_kind => "ASYNC" )
    PORT MAP ( xin => STD_LOGIC_VECTOR(prodXY_uid179_pT2_uid167_invPolyEval_cma_s(0)(37 downto 0)), xout => prodXY_uid179_pT2_uid167_invPolyEval_cma_qq, clk => clk, aclr => areset );
    prodXY_uid179_pT2_uid167_invPolyEval_cma_q <= STD_LOGIC_VECTOR(prodXY_uid179_pT2_uid167_invPolyEval_cma_qq(37 downto 0));

    -- osig_uid180_pT2_uid167_invPolyEval(BITSELECT,179)@7
    osig_uid180_pT2_uid167_invPolyEval_in <= STD_LOGIC_VECTOR(prodXY_uid179_pT2_uid167_invPolyEval_cma_q);
    osig_uid180_pT2_uid167_invPolyEval_b <= osig_uid180_pT2_uid167_invPolyEval_in(37 downto 13);

    -- highBBits_uid169_invPolyEval(BITSELECT,168)@7
    highBBits_uid169_invPolyEval_in <= STD_LOGIC_VECTOR(osig_uid180_pT2_uid167_invPolyEval_b);
    highBBits_uid169_invPolyEval_b <= highBBits_uid169_invPolyEval_in(24 downto 2);

    -- redist0(DELAY,190)
    redist0 : dspba_delay
    GENERIC MAP ( width => 23, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => highBBits_uid169_invPolyEval_b, xout => redist0_q, clk => clk, aclr => areset );

    -- redist27(DELAY,217)
    redist27 : dspba_delay
    GENERIC MAP ( width => 9, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist26_q, xout => redist27_q, clk => clk, aclr => areset );

    -- memoryC0_uid147_invTables_lutmem(DUALMEM,182)@5
    memoryC0_uid147_invTables_lutmem_aa <= redist27_q;
    memoryC0_uid147_invTables_lutmem_reset0 <= areset;
    memoryC0_uid147_invTables_lutmem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "M10K",
        operation_mode => "ROM",
        width_a => 12,
        widthad_a => 9,
        numwords_a => 512,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "fpdiv14_0002_memoryC0_uid147_invTables_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken0 => VCC_q(0),
        aclr0 => memoryC0_uid147_invTables_lutmem_reset0,
        clock0 => clk,
        address_a => memoryC0_uid147_invTables_lutmem_aa,
        q_a => memoryC0_uid147_invTables_lutmem_ir
    );
    memoryC0_uid147_invTables_lutmem_r <= memoryC0_uid147_invTables_lutmem_ir(11 downto 0);

    -- memoryC0_uid146_invTables_lutmem(DUALMEM,181)@5
    memoryC0_uid146_invTables_lutmem_aa <= redist27_q;
    memoryC0_uid146_invTables_lutmem_reset0 <= areset;
    memoryC0_uid146_invTables_lutmem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "M10K",
        operation_mode => "ROM",
        width_a => 20,
        widthad_a => 9,
        numwords_a => 512,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "fpdiv14_0002_memoryC0_uid146_invTables_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken0 => VCC_q(0),
        aclr0 => memoryC0_uid146_invTables_lutmem_reset0,
        clock0 => clk,
        address_a => memoryC0_uid146_invTables_lutmem_aa,
        q_a => memoryC0_uid146_invTables_lutmem_ir
    );
    memoryC0_uid146_invTables_lutmem_r <= memoryC0_uid146_invTables_lutmem_ir(19 downto 0);

    -- os_uid148_invTables(BITJOIN,147)@7
    os_uid148_invTables_q <= memoryC0_uid147_invTables_lutmem_r & memoryC0_uid146_invTables_lutmem_r;

    -- redist3(DELAY,193)
    redist3 : dspba_delay
    GENERIC MAP ( width => 32, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => os_uid148_invTables_q, xout => redist3_q, clk => clk, aclr => areset );

    -- s2sumAHighB_uid170_invPolyEval(ADD,169)@8
    s2sumAHighB_uid170_invPolyEval_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((32 downto 32 => redist3_q(31)) & redist3_q));
    s2sumAHighB_uid170_invPolyEval_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((32 downto 23 => redist0_q(22)) & redist0_q));
    s2sumAHighB_uid170_invPolyEval_o <= STD_LOGIC_VECTOR(SIGNED(s2sumAHighB_uid170_invPolyEval_a) + SIGNED(s2sumAHighB_uid170_invPolyEval_b));
    s2sumAHighB_uid170_invPolyEval_q <= s2sumAHighB_uid170_invPolyEval_o(32 downto 0);

    -- lowRangeB_uid168_invPolyEval(BITSELECT,167)@7
    lowRangeB_uid168_invPolyEval_in <= osig_uid180_pT2_uid167_invPolyEval_b(1 downto 0);
    lowRangeB_uid168_invPolyEval_b <= lowRangeB_uid168_invPolyEval_in(1 downto 0);

    -- redist1(DELAY,191)
    redist1 : dspba_delay
    GENERIC MAP ( width => 2, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => lowRangeB_uid168_invPolyEval_b, xout => redist1_q, clk => clk, aclr => areset );

    -- s2_uid171_invPolyEval(BITJOIN,170)@8
    s2_uid171_invPolyEval_q <= s2sumAHighB_uid170_invPolyEval_q & redist1_q;

    -- invY_uid54_fpDivTest(BITSELECT,53)@8
    invY_uid54_fpDivTest_in <= s2_uid171_invPolyEval_q(31 downto 0);
    invY_uid54_fpDivTest_b <= invY_uid54_fpDivTest_in(31 downto 5);

    -- redist23(DELAY,213)
    redist23 : dspba_delay
    GENERIC MAP ( width => 27, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => invY_uid54_fpDivTest_b, xout => redist23_q, clk => clk, aclr => areset );

    -- prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma(CHAINMULTADD,187)@9
    prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_p(0) <= prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_a0(0) * prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_c0(0);
    prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_u(0) <= RESIZE(prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_p(0),51);
    prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_w(0) <= prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_u(0);
    prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_x(0) <= prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_w(0);
    prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_y(0) <= prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_x(0);
    prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_chainmultadd: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_a0 <= (others => (others => '0'));
            prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_c0 <= (others => (others => '0'));
            prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_s <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_a0(0) <= RESIZE(UNSIGNED(redist23_q),27);
            prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_c0(0) <= RESIZE(UNSIGNED(lOAdded_uid57_fpDivTest_q),24);
            prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_s(0) <= prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_y(0);
        END IF;
    END PROCESS;
    prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_delay : dspba_delay
    GENERIC MAP ( width => 51, depth => 0, reset_kind => "ASYNC" )
    PORT MAP ( xin => STD_LOGIC_VECTOR(prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_s(0)(50 downto 0)), xout => prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_qq, clk => clk, aclr => areset );
    prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_q <= STD_LOGIC_VECTOR(prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_qq(50 downto 0));

    -- osig_uid174_divValPreNorm_uid59_fpDivTest(BITSELECT,173)@11
    osig_uid174_divValPreNorm_uid59_fpDivTest_in <= prodXY_uid173_divValPreNorm_uid59_fpDivTest_cma_q;
    osig_uid174_divValPreNorm_uid59_fpDivTest_b <= osig_uid174_divValPreNorm_uid59_fpDivTest_in(50 downto 23);

    -- updatedY_uid16_fpDivTest(BITJOIN,15)@10
    updatedY_uid16_fpDivTest_q <= GND_q & paddingY_uid15_fpDivTest_q;

    -- fracYZero_uid15_fpDivTest(LOGICAL,16)@10
    fracYZero_uid15_fpDivTest_a <= STD_LOGIC_VECTOR("0" & redist29_outputreg_q);
    fracYZero_uid15_fpDivTest_b <= updatedY_uid16_fpDivTest_q;
    fracYZero_uid15_fpDivTest_q_i <= "1" WHEN fracYZero_uid15_fpDivTest_a = fracYZero_uid15_fpDivTest_b ELSE "0";
    fracYZero_uid15_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracYZero_uid15_fpDivTest_q_i, xout => fracYZero_uid15_fpDivTest_q, clk => clk, aclr => areset );

    -- divValPreNormYPow2Exc_uid63_fpDivTest(MUX,62)@11
    divValPreNormYPow2Exc_uid63_fpDivTest_s <= fracYZero_uid15_fpDivTest_q;
    divValPreNormYPow2Exc_uid63_fpDivTest: PROCESS (divValPreNormYPow2Exc_uid63_fpDivTest_s, osig_uid174_divValPreNorm_uid59_fpDivTest_b, oFracXZ4_uid61_fpDivTest_q)
    BEGIN
        CASE (divValPreNormYPow2Exc_uid63_fpDivTest_s) IS
            WHEN "0" => divValPreNormYPow2Exc_uid63_fpDivTest_q <= osig_uid174_divValPreNorm_uid59_fpDivTest_b;
            WHEN "1" => divValPreNormYPow2Exc_uid63_fpDivTest_q <= oFracXZ4_uid61_fpDivTest_q;
            WHEN OTHERS => divValPreNormYPow2Exc_uid63_fpDivTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- norm_uid64_fpDivTest(BITSELECT,63)@11
    norm_uid64_fpDivTest_in <= STD_LOGIC_VECTOR(divValPreNormYPow2Exc_uid63_fpDivTest_q);
    norm_uid64_fpDivTest_b <= norm_uid64_fpDivTest_in(27 downto 27);

    -- redist19(DELAY,209)
    redist19 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => norm_uid64_fpDivTest_b, xout => redist19_q, clk => clk, aclr => areset );

    -- zeroPaddingInAddition_uid74_fpDivTest(CONSTANT,73)
    zeroPaddingInAddition_uid74_fpDivTest_q <= "000000000000000000000000";

    -- expFracPostRnd_uid75_fpDivTest(BITJOIN,74)@12
    expFracPostRnd_uid75_fpDivTest_q <= redist19_q & zeroPaddingInAddition_uid74_fpDivTest_q & VCC_q;

    -- cstBiasM1_uid6_fpDivTest(CONSTANT,5)
    cstBiasM1_uid6_fpDivTest_q <= "01111110";

    -- expXmY_uid47_fpDivTest(SUB,46)@10
    expXmY_uid47_fpDivTest_a <= STD_LOGIC_VECTOR("0" & redist36_outputreg_q);
    expXmY_uid47_fpDivTest_b <= STD_LOGIC_VECTOR("0" & redist31_outputreg_q);
    expXmY_uid47_fpDivTest: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expXmY_uid47_fpDivTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            expXmY_uid47_fpDivTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expXmY_uid47_fpDivTest_a) - UNSIGNED(expXmY_uid47_fpDivTest_b));
        END IF;
    END PROCESS;
    expXmY_uid47_fpDivTest_q <= expXmY_uid47_fpDivTest_o(8 downto 0);

    -- expR_uid48_fpDivTest(ADD,47)@11
    expR_uid48_fpDivTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((10 downto 9 => expXmY_uid47_fpDivTest_q(8)) & expXmY_uid47_fpDivTest_q));
    expR_uid48_fpDivTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("0" & "00" & cstBiasM1_uid6_fpDivTest_q));
    expR_uid48_fpDivTest_o <= STD_LOGIC_VECTOR(SIGNED(expR_uid48_fpDivTest_a) + SIGNED(expR_uid48_fpDivTest_b));
    expR_uid48_fpDivTest_q <= expR_uid48_fpDivTest_o(9 downto 0);

    -- divValPreNormHigh_uid65_fpDivTest(BITSELECT,64)@11
    divValPreNormHigh_uid65_fpDivTest_in <= divValPreNormYPow2Exc_uid63_fpDivTest_q(26 downto 0);
    divValPreNormHigh_uid65_fpDivTest_b <= divValPreNormHigh_uid65_fpDivTest_in(26 downto 2);

    -- divValPreNormLow_uid66_fpDivTest(BITSELECT,65)@11
    divValPreNormLow_uid66_fpDivTest_in <= divValPreNormYPow2Exc_uid63_fpDivTest_q(25 downto 0);
    divValPreNormLow_uid66_fpDivTest_b <= divValPreNormLow_uid66_fpDivTest_in(25 downto 1);

    -- normFracRnd_uid67_fpDivTest(MUX,66)@11
    normFracRnd_uid67_fpDivTest_s <= norm_uid64_fpDivTest_b;
    normFracRnd_uid67_fpDivTest: PROCESS (normFracRnd_uid67_fpDivTest_s, divValPreNormLow_uid66_fpDivTest_b, divValPreNormHigh_uid65_fpDivTest_b)
    BEGIN
        CASE (normFracRnd_uid67_fpDivTest_s) IS
            WHEN "0" => normFracRnd_uid67_fpDivTest_q <= divValPreNormLow_uid66_fpDivTest_b;
            WHEN "1" => normFracRnd_uid67_fpDivTest_q <= divValPreNormHigh_uid65_fpDivTest_b;
            WHEN OTHERS => normFracRnd_uid67_fpDivTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- expFracRnd_uid68_fpDivTest(BITJOIN,67)@11
    expFracRnd_uid68_fpDivTest_q <= expR_uid48_fpDivTest_q & normFracRnd_uid67_fpDivTest_q;

    -- redist18(DELAY,208)
    redist18 : dspba_delay
    GENERIC MAP ( width => 35, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => expFracRnd_uid68_fpDivTest_q, xout => redist18_q, clk => clk, aclr => areset );

    -- expFracPostRnd_uid76_fpDivTest(ADD,75)@12
    expFracPostRnd_uid76_fpDivTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((36 downto 35 => redist18_q(34)) & redist18_q));
    expFracPostRnd_uid76_fpDivTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("0" & "0000000000" & expFracPostRnd_uid75_fpDivTest_q));
    expFracPostRnd_uid76_fpDivTest: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expFracPostRnd_uid76_fpDivTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            expFracPostRnd_uid76_fpDivTest_o <= STD_LOGIC_VECTOR(SIGNED(expFracPostRnd_uid76_fpDivTest_a) + SIGNED(expFracPostRnd_uid76_fpDivTest_b));
        END IF;
    END PROCESS;
    expFracPostRnd_uid76_fpDivTest_q <= expFracPostRnd_uid76_fpDivTest_o(35 downto 0);

    -- fracPostRndF_uid79_fpDivTest(BITSELECT,78)@13
    fracPostRndF_uid79_fpDivTest_in <= expFracPostRnd_uid76_fpDivTest_q(24 downto 0);
    fracPostRndF_uid79_fpDivTest_b <= fracPostRndF_uid79_fpDivTest_in(24 downto 1);

    -- invYO_uid55_fpDivTest(BITSELECT,54)@8
    invYO_uid55_fpDivTest_in <= STD_LOGIC_VECTOR(s2_uid171_invPolyEval_q(32 downto 0));
    invYO_uid55_fpDivTest_b <= invYO_uid55_fpDivTest_in(32 downto 32);

    -- redist21(DELAY,211)
    redist21 : dspba_delay
    GENERIC MAP ( width => 1, depth => 5, reset_kind => "ASYNC" )
    PORT MAP ( xin => invYO_uid55_fpDivTest_b, xout => redist21_q, clk => clk, aclr => areset );

    -- fracPostRndF_uid80_fpDivTest(MUX,79)@13
    fracPostRndF_uid80_fpDivTest_s <= redist21_q;
    fracPostRndF_uid80_fpDivTest: PROCESS (fracPostRndF_uid80_fpDivTest_s, fracPostRndF_uid79_fpDivTest_b, fracXExt_uid77_fpDivTest_q)
    BEGIN
        CASE (fracPostRndF_uid80_fpDivTest_s) IS
            WHEN "0" => fracPostRndF_uid80_fpDivTest_q <= fracPostRndF_uid79_fpDivTest_b;
            WHEN "1" => fracPostRndF_uid80_fpDivTest_q <= fracXExt_uid77_fpDivTest_q;
            WHEN OTHERS => fracPostRndF_uid80_fpDivTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- betweenFPwF_uid102_fpDivTest(BITSELECT,101)@13
    betweenFPwF_uid102_fpDivTest_in <= STD_LOGIC_VECTOR(fracPostRndF_uid80_fpDivTest_q(0 downto 0));
    betweenFPwF_uid102_fpDivTest_b <= betweenFPwF_uid102_fpDivTest_in(0 downto 0);

    -- redist11(DELAY,201)
    redist11 : dspba_delay
    GENERIC MAP ( width => 1, depth => 4, reset_kind => "ASYNC" )
    PORT MAP ( xin => betweenFPwF_uid102_fpDivTest_b, xout => redist11_q, clk => clk, aclr => areset );

    -- redist35(DELAY,225)
    redist35 : dspba_delay
    GENERIC MAP ( width => 23, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist34_q, xout => redist35_q, clk => clk, aclr => areset );

    -- qDivProdLTX_opB_uid100_fpDivTest(BITJOIN,99)@14
    qDivProdLTX_opB_uid100_fpDivTest_q <= redist37_q & redist35_q;

    -- redist12_inputreg(DELAY,239)
    redist12_inputreg : dspba_delay
    GENERIC MAP ( width => 31, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => qDivProdLTX_opB_uid100_fpDivTest_q, xout => redist12_inputreg_q, clk => clk, aclr => areset );

    -- redist12(DELAY,202)
    redist12 : dspba_delay
    GENERIC MAP ( width => 31, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist12_inputreg_q, xout => redist12_q, clk => clk, aclr => areset );

    -- lOAdded_uid87_fpDivTest(BITJOIN,86)@13
    lOAdded_uid87_fpDivTest_q <= VCC_q & redist30_q;

    -- lOAdded_uid84_fpDivTest(BITJOIN,83)@13
    lOAdded_uid84_fpDivTest_q <= VCC_q & fracPostRndF_uid80_fpDivTest_q;

    -- qDivProd_uid89_fpDivTest_cma(CHAINMULTADD,186)@13
    qDivProd_uid89_fpDivTest_cma_p(0) <= qDivProd_uid89_fpDivTest_cma_a0(0) * qDivProd_uid89_fpDivTest_cma_c0(0);
    qDivProd_uid89_fpDivTest_cma_u(0) <= RESIZE(qDivProd_uid89_fpDivTest_cma_p(0),49);
    qDivProd_uid89_fpDivTest_cma_w(0) <= qDivProd_uid89_fpDivTest_cma_u(0);
    qDivProd_uid89_fpDivTest_cma_x(0) <= qDivProd_uid89_fpDivTest_cma_w(0);
    qDivProd_uid89_fpDivTest_cma_y(0) <= qDivProd_uid89_fpDivTest_cma_x(0);
    qDivProd_uid89_fpDivTest_cma_chainmultadd: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            qDivProd_uid89_fpDivTest_cma_a0 <= (others => (others => '0'));
            qDivProd_uid89_fpDivTest_cma_c0 <= (others => (others => '0'));
            qDivProd_uid89_fpDivTest_cma_s <= (others => (others => '0'));
        ELSIF (clk'EVENT AND clk = '1') THEN
            qDivProd_uid89_fpDivTest_cma_a0(0) <= RESIZE(UNSIGNED(lOAdded_uid84_fpDivTest_q),25);
            qDivProd_uid89_fpDivTest_cma_c0(0) <= RESIZE(UNSIGNED(lOAdded_uid87_fpDivTest_q),24);
            qDivProd_uid89_fpDivTest_cma_s(0) <= qDivProd_uid89_fpDivTest_cma_y(0);
        END IF;
    END PROCESS;
    qDivProd_uid89_fpDivTest_cma_delay : dspba_delay
    GENERIC MAP ( width => 49, depth => 0, reset_kind => "ASYNC" )
    PORT MAP ( xin => STD_LOGIC_VECTOR(qDivProd_uid89_fpDivTest_cma_s(0)(48 downto 0)), xout => qDivProd_uid89_fpDivTest_cma_qq, clk => clk, aclr => areset );
    qDivProd_uid89_fpDivTest_cma_q <= STD_LOGIC_VECTOR(qDivProd_uid89_fpDivTest_cma_qq(48 downto 0));

    -- qDivProdNorm_uid90_fpDivTest(BITSELECT,89)@15
    qDivProdNorm_uid90_fpDivTest_in <= STD_LOGIC_VECTOR(qDivProd_uid89_fpDivTest_cma_q);
    qDivProdNorm_uid90_fpDivTest_b <= qDivProdNorm_uid90_fpDivTest_in(48 downto 48);

    -- cstBias_uid7_fpDivTest(CONSTANT,6)
    cstBias_uid7_fpDivTest_q <= "01111111";

    -- qDivProdExp_opBs_uid95_fpDivTest(SUB,94)@15
    qDivProdExp_opBs_uid95_fpDivTest_a <= STD_LOGIC_VECTOR("0" & cstBias_uid7_fpDivTest_q);
    qDivProdExp_opBs_uid95_fpDivTest_b <= STD_LOGIC_VECTOR("00000000" & qDivProdNorm_uid90_fpDivTest_b);
    qDivProdExp_opBs_uid95_fpDivTest: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            qDivProdExp_opBs_uid95_fpDivTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            qDivProdExp_opBs_uid95_fpDivTest_o <= STD_LOGIC_VECTOR(UNSIGNED(qDivProdExp_opBs_uid95_fpDivTest_a) - UNSIGNED(qDivProdExp_opBs_uid95_fpDivTest_b));
        END IF;
    END PROCESS;
    qDivProdExp_opBs_uid95_fpDivTest_q <= qDivProdExp_opBs_uid95_fpDivTest_o(8 downto 0);

    -- expPostRndFR_uid81_fpDivTest(BITSELECT,80)@13
    expPostRndFR_uid81_fpDivTest_in <= expFracPostRnd_uid76_fpDivTest_q(32 downto 0);
    expPostRndFR_uid81_fpDivTest_b <= expPostRndFR_uid81_fpDivTest_in(32 downto 25);

    -- redist16(DELAY,206)
    redist16 : dspba_delay
    GENERIC MAP ( width => 8, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => expPostRndFR_uid81_fpDivTest_b, xout => redist16_q, clk => clk, aclr => areset );

    -- redist22(DELAY,212)
    redist22 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist21_q, xout => redist22_q, clk => clk, aclr => areset );

    -- expPostRndF_uid82_fpDivTest(MUX,81)@14
    expPostRndF_uid82_fpDivTest_s <= redist22_q;
    expPostRndF_uid82_fpDivTest: PROCESS (expPostRndF_uid82_fpDivTest_s, redist16_q, redist37_q)
    BEGIN
        CASE (expPostRndF_uid82_fpDivTest_s) IS
            WHEN "0" => expPostRndF_uid82_fpDivTest_q <= redist16_q;
            WHEN "1" => expPostRndF_uid82_fpDivTest_q <= redist37_q;
            WHEN OTHERS => expPostRndF_uid82_fpDivTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- qDivProdExp_opA_uid94_fpDivTest(ADD,93)@14
    qDivProdExp_opA_uid94_fpDivTest_a <= STD_LOGIC_VECTOR("0" & redist32_q);
    qDivProdExp_opA_uid94_fpDivTest_b <= STD_LOGIC_VECTOR("0" & expPostRndF_uid82_fpDivTest_q);
    qDivProdExp_opA_uid94_fpDivTest: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            qDivProdExp_opA_uid94_fpDivTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            qDivProdExp_opA_uid94_fpDivTest_o <= STD_LOGIC_VECTOR(UNSIGNED(qDivProdExp_opA_uid94_fpDivTest_a) + UNSIGNED(qDivProdExp_opA_uid94_fpDivTest_b));
        END IF;
    END PROCESS;
    qDivProdExp_opA_uid94_fpDivTest_q <= qDivProdExp_opA_uid94_fpDivTest_o(8 downto 0);

    -- redist15(DELAY,205)
    redist15 : dspba_delay
    GENERIC MAP ( width => 9, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => qDivProdExp_opA_uid94_fpDivTest_q, xout => redist15_q, clk => clk, aclr => areset );

    -- qDivProdExp_uid96_fpDivTest(SUB,95)@16
    qDivProdExp_uid96_fpDivTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("0" & "00" & redist15_q));
    qDivProdExp_uid96_fpDivTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((11 downto 9 => qDivProdExp_opBs_uid95_fpDivTest_q(8)) & qDivProdExp_opBs_uid95_fpDivTest_q));
    qDivProdExp_uid96_fpDivTest_o <= STD_LOGIC_VECTOR(SIGNED(qDivProdExp_uid96_fpDivTest_a) - SIGNED(qDivProdExp_uid96_fpDivTest_b));
    qDivProdExp_uid96_fpDivTest_q <= qDivProdExp_uid96_fpDivTest_o(10 downto 0);

    -- qDivProdLTX_opA_uid98_fpDivTest(BITSELECT,97)@16
    qDivProdLTX_opA_uid98_fpDivTest_in <= qDivProdExp_uid96_fpDivTest_q(7 downto 0);
    qDivProdLTX_opA_uid98_fpDivTest_b <= qDivProdLTX_opA_uid98_fpDivTest_in(7 downto 0);

    -- qDivProdFracHigh_uid91_fpDivTest(BITSELECT,90)@15
    qDivProdFracHigh_uid91_fpDivTest_in <= qDivProd_uid89_fpDivTest_cma_q(47 downto 0);
    qDivProdFracHigh_uid91_fpDivTest_b <= qDivProdFracHigh_uid91_fpDivTest_in(47 downto 24);

    -- qDivProdFracLow_uid92_fpDivTest(BITSELECT,91)@15
    qDivProdFracLow_uid92_fpDivTest_in <= qDivProd_uid89_fpDivTest_cma_q(46 downto 0);
    qDivProdFracLow_uid92_fpDivTest_b <= qDivProdFracLow_uid92_fpDivTest_in(46 downto 23);

    -- qDivProdFrac_uid93_fpDivTest(MUX,92)@15
    qDivProdFrac_uid93_fpDivTest_s <= qDivProdNorm_uid90_fpDivTest_b;
    qDivProdFrac_uid93_fpDivTest: PROCESS (qDivProdFrac_uid93_fpDivTest_s, qDivProdFracLow_uid92_fpDivTest_b, qDivProdFracHigh_uid91_fpDivTest_b)
    BEGIN
        CASE (qDivProdFrac_uid93_fpDivTest_s) IS
            WHEN "0" => qDivProdFrac_uid93_fpDivTest_q <= qDivProdFracLow_uid92_fpDivTest_b;
            WHEN "1" => qDivProdFrac_uid93_fpDivTest_q <= qDivProdFracHigh_uid91_fpDivTest_b;
            WHEN OTHERS => qDivProdFrac_uid93_fpDivTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- qDivProdFracWF_uid97_fpDivTest(BITSELECT,96)@15
    qDivProdFracWF_uid97_fpDivTest_in <= qDivProdFrac_uid93_fpDivTest_q;
    qDivProdFracWF_uid97_fpDivTest_b <= qDivProdFracWF_uid97_fpDivTest_in(23 downto 1);

    -- redist14(DELAY,204)
    redist14 : dspba_delay
    GENERIC MAP ( width => 23, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => qDivProdFracWF_uid97_fpDivTest_b, xout => redist14_q, clk => clk, aclr => areset );

    -- qDivProdLTX_opA_uid99_fpDivTest(BITJOIN,98)@16
    qDivProdLTX_opA_uid99_fpDivTest_q <= qDivProdLTX_opA_uid98_fpDivTest_b & redist14_q;

    -- redist13(DELAY,203)
    redist13 : dspba_delay
    GENERIC MAP ( width => 31, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => qDivProdLTX_opA_uid99_fpDivTest_q, xout => redist13_q, clk => clk, aclr => areset );

    -- qDividerProdLTX_uid101_fpDivTest(COMPARE,100)@17
    qDividerProdLTX_uid101_fpDivTest_cin <= GND_q;
    qDividerProdLTX_uid101_fpDivTest_a <= STD_LOGIC_VECTOR("00" & redist13_q) & '0';
    qDividerProdLTX_uid101_fpDivTest_b <= STD_LOGIC_VECTOR("00" & redist12_q) & qDividerProdLTX_uid101_fpDivTest_cin(0);
    qDividerProdLTX_uid101_fpDivTest_o <= STD_LOGIC_VECTOR(UNSIGNED(qDividerProdLTX_uid101_fpDivTest_a) - UNSIGNED(qDividerProdLTX_uid101_fpDivTest_b));
    qDividerProdLTX_uid101_fpDivTest_c(0) <= qDividerProdLTX_uid101_fpDivTest_o(33);

    -- extraUlp_uid103_fpDivTest(LOGICAL,102)@17
    extraUlp_uid103_fpDivTest_a <= qDividerProdLTX_uid101_fpDivTest_c;
    extraUlp_uid103_fpDivTest_b <= redist11_q;
    extraUlp_uid103_fpDivTest_q_i <= extraUlp_uid103_fpDivTest_a and extraUlp_uid103_fpDivTest_b;
    extraUlp_uid103_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => extraUlp_uid103_fpDivTest_q_i, xout => extraUlp_uid103_fpDivTest_q, clk => clk, aclr => areset );

    -- redist8_notEnable(LOGICAL,235)
    redist8_notEnable_a <= VCC_q;
    redist8_notEnable_q <= not (redist8_notEnable_a);

    -- redist8_nor(LOGICAL,236)
    redist8_nor_a <= redist8_notEnable_q;
    redist8_nor_b <= redist8_sticky_ena_q;
    redist8_nor_q <= not (redist8_nor_a or redist8_nor_b);

    -- redist8_mem_top(CONSTANT,232)
    redist8_mem_top_q <= "010";

    -- redist8_cmp(LOGICAL,233)
    redist8_cmp_a <= redist8_mem_top_q;
    redist8_cmp_b <= STD_LOGIC_VECTOR("0" & redist8_rdcnt_q);
    redist8_cmp_q <= "1" WHEN redist8_cmp_a = redist8_cmp_b ELSE "0";

    -- redist8_cmpReg(REG,234)
    redist8_cmpReg: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist8_cmpReg_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist8_cmpReg_q <= STD_LOGIC_VECTOR(redist8_cmp_q);
        END IF;
    END PROCESS;

    -- redist8_sticky_ena(REG,237)
    redist8_sticky_ena: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist8_sticky_ena_q <= "0";
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist8_nor_q = "1") THEN
                redist8_sticky_ena_q <= STD_LOGIC_VECTOR(redist8_cmpReg_q);
            END IF;
        END IF;
    END PROCESS;

    -- redist8_enaAnd(LOGICAL,238)
    redist8_enaAnd_a <= redist8_sticky_ena_q;
    redist8_enaAnd_b <= VCC_q;
    redist8_enaAnd_q <= redist8_enaAnd_a and redist8_enaAnd_b;

    -- redist8_rdcnt(COUNTER,230)
    -- every=1, low=0, high=2, step=1, init=1
    redist8_rdcnt: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist8_rdcnt_i <= TO_UNSIGNED(1, 2);
            redist8_rdcnt_eq <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (redist8_rdcnt_i = TO_UNSIGNED(1, 2)) THEN
                redist8_rdcnt_eq <= '1';
            ELSE
                redist8_rdcnt_eq <= '0';
            END IF;
            IF (redist8_rdcnt_eq = '1') THEN
                redist8_rdcnt_i <= redist8_rdcnt_i - 2;
            ELSE
                redist8_rdcnt_i <= redist8_rdcnt_i + 1;
            END IF;
        END IF;
    END PROCESS;
    redist8_rdcnt_q <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR(RESIZE(redist8_rdcnt_i, 2)));

    -- fracPostRndFT_uid104_fpDivTest(BITSELECT,103)@13
    fracPostRndFT_uid104_fpDivTest_in <= fracPostRndF_uid80_fpDivTest_q;
    fracPostRndFT_uid104_fpDivTest_b <= fracPostRndFT_uid104_fpDivTest_in(23 downto 1);

    -- redist8_wraddr(REG,231)
    redist8_wraddr: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            redist8_wraddr_q <= "00";
        ELSIF (clk'EVENT AND clk = '1') THEN
            redist8_wraddr_q <= STD_LOGIC_VECTOR(redist8_rdcnt_q);
        END IF;
    END PROCESS;

    -- redist8_mem(DUALMEM,229)
    redist8_mem_ia <= STD_LOGIC_VECTOR(fracPostRndFT_uid104_fpDivTest_b);
    redist8_mem_aa <= redist8_wraddr_q;
    redist8_mem_ab <= redist8_rdcnt_q;
    redist8_mem_reset0 <= areset;
    redist8_mem_dmem : altera_syncram
    GENERIC MAP (
        ram_block_type => "MLAB",
        operation_mode => "DUAL_PORT",
        width_a => 23,
        widthad_a => 2,
        numwords_a => 3,
        width_b => 23,
        widthad_b => 2,
        numwords_b => 3,
        lpm_type => "altera_syncram",
        width_byteena_a => 1,
        address_reg_b => "CLOCK0",
        indata_reg_b => "CLOCK0",
        rdcontrol_reg_b => "CLOCK0",
        byteena_reg_b => "CLOCK0",
        outdata_reg_b => "CLOCK1",
        outdata_aclr_b => "CLEAR1",
        clock_enable_input_a => "NORMAL",
        clock_enable_input_b => "NORMAL",
        clock_enable_output_b => "NORMAL",
        read_during_write_mode_mixed_ports => "DONT_CARE",
        power_up_uninitialized => "TRUE",
        intended_device_family => "Cyclone V"
    )
    PORT MAP (
        clocken1 => redist8_enaAnd_q(0),
        clocken0 => VCC_q(0),
        clock0 => clk,
        aclr1 => redist8_mem_reset0,
        clock1 => clk,
        address_a => redist8_mem_aa,
        data_a => redist8_mem_ia,
        wren_a => VCC_q(0),
        address_b => redist8_mem_ab,
        q_b => redist8_mem_iq
    );
    redist8_mem_q <= redist8_mem_iq(22 downto 0);

    -- redist8_outputreg(DELAY,228)
    redist8_outputreg : dspba_delay
    GENERIC MAP ( width => 23, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist8_mem_q, xout => redist8_outputreg_q, clk => clk, aclr => areset );

    -- fracRPreExcExt_uid105_fpDivTest(ADD,104)@18
    fracRPreExcExt_uid105_fpDivTest_a <= STD_LOGIC_VECTOR("0" & redist8_outputreg_q);
    fracRPreExcExt_uid105_fpDivTest_b <= STD_LOGIC_VECTOR("00000000000000000000000" & extraUlp_uid103_fpDivTest_q);
    fracRPreExcExt_uid105_fpDivTest: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            fracRPreExcExt_uid105_fpDivTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            fracRPreExcExt_uid105_fpDivTest_o <= STD_LOGIC_VECTOR(UNSIGNED(fracRPreExcExt_uid105_fpDivTest_a) + UNSIGNED(fracRPreExcExt_uid105_fpDivTest_b));
        END IF;
    END PROCESS;
    fracRPreExcExt_uid105_fpDivTest_q <= fracRPreExcExt_uid105_fpDivTest_o(23 downto 0);

    -- ovfIncRnd_uid109_fpDivTest(BITSELECT,108)@19
    ovfIncRnd_uid109_fpDivTest_in <= STD_LOGIC_VECTOR(fracRPreExcExt_uid105_fpDivTest_q);
    ovfIncRnd_uid109_fpDivTest_b <= ovfIncRnd_uid109_fpDivTest_in(23 downto 23);

    -- expFracPostRndInc_uid110_fpDivTest(ADD,109)@19
    expFracPostRndInc_uid110_fpDivTest_a <= STD_LOGIC_VECTOR("0" & redist17_outputreg_q);
    expFracPostRndInc_uid110_fpDivTest_b <= STD_LOGIC_VECTOR("00000000" & ovfIncRnd_uid109_fpDivTest_b);
    expFracPostRndInc_uid110_fpDivTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expFracPostRndInc_uid110_fpDivTest_a) + UNSIGNED(expFracPostRndInc_uid110_fpDivTest_b));
    expFracPostRndInc_uid110_fpDivTest_q <= expFracPostRndInc_uid110_fpDivTest_o(8 downto 0);

    -- expFracPostRndR_uid111_fpDivTest(BITSELECT,110)@19
    expFracPostRndR_uid111_fpDivTest_in <= expFracPostRndInc_uid110_fpDivTest_q(7 downto 0);
    expFracPostRndR_uid111_fpDivTest_b <= expFracPostRndR_uid111_fpDivTest_in(7 downto 0);

    -- redist17(DELAY,207)
    redist17 : dspba_delay
    GENERIC MAP ( width => 8, depth => 4, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist16_q, xout => redist17_q, clk => clk, aclr => areset );

    -- redist17_outputreg(DELAY,240)
    redist17_outputreg : dspba_delay
    GENERIC MAP ( width => 8, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist17_q, xout => redist17_outputreg_q, clk => clk, aclr => areset );

    -- redist10(DELAY,200)
    redist10 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => extraUlp_uid103_fpDivTest_q, xout => redist10_q, clk => clk, aclr => areset );

    -- expRPreExc_uid112_fpDivTest(MUX,111)@19
    expRPreExc_uid112_fpDivTest_s <= redist10_q;
    expRPreExc_uid112_fpDivTest: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expRPreExc_uid112_fpDivTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (expRPreExc_uid112_fpDivTest_s) IS
                WHEN "0" => expRPreExc_uid112_fpDivTest_q <= redist17_outputreg_q;
                WHEN "1" => expRPreExc_uid112_fpDivTest_q <= expFracPostRndR_uid111_fpDivTest_b;
                WHEN OTHERS => expRPreExc_uid112_fpDivTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- invExpXIsMax_uid43_fpDivTest(LOGICAL,42)@14
    invExpXIsMax_uid43_fpDivTest_a <= expXIsMax_uid38_fpDivTest_q;
    invExpXIsMax_uid43_fpDivTest_q <= not (invExpXIsMax_uid43_fpDivTest_a);

    -- InvExpXIsZero_uid44_fpDivTest(LOGICAL,43)@14
    InvExpXIsZero_uid44_fpDivTest_a <= excZ_y_uid37_fpDivTest_q;
    InvExpXIsZero_uid44_fpDivTest_q <= not (InvExpXIsZero_uid44_fpDivTest_a);

    -- excR_y_uid45_fpDivTest(LOGICAL,44)@14
    excR_y_uid45_fpDivTest_a <= InvExpXIsZero_uid44_fpDivTest_q;
    excR_y_uid45_fpDivTest_b <= invExpXIsMax_uid43_fpDivTest_q;
    excR_y_uid45_fpDivTest_q <= excR_y_uid45_fpDivTest_a and excR_y_uid45_fpDivTest_b;

    -- excXIYR_uid127_fpDivTest(LOGICAL,126)@14
    excXIYR_uid127_fpDivTest_a <= excI_x_uid27_fpDivTest_q;
    excXIYR_uid127_fpDivTest_b <= excR_y_uid45_fpDivTest_q;
    excXIYR_uid127_fpDivTest_q <= excXIYR_uid127_fpDivTest_a and excXIYR_uid127_fpDivTest_b;

    -- excXIYZ_uid126_fpDivTest(LOGICAL,125)@14
    excXIYZ_uid126_fpDivTest_a <= excI_x_uid27_fpDivTest_q;
    excXIYZ_uid126_fpDivTest_b <= excZ_y_uid37_fpDivTest_q;
    excXIYZ_uid126_fpDivTest_q <= excXIYZ_uid126_fpDivTest_a and excXIYZ_uid126_fpDivTest_b;

    -- expRExt_uid114_fpDivTest(BITSELECT,113)@13
    expRExt_uid114_fpDivTest_in <= STD_LOGIC_VECTOR(expFracPostRnd_uid76_fpDivTest_q);
    expRExt_uid114_fpDivTest_b <= expRExt_uid114_fpDivTest_in(35 downto 25);

    -- expOvf_uid118_fpDivTest(COMPARE,117)@13
    expOvf_uid118_fpDivTest_cin <= GND_q;
    expOvf_uid118_fpDivTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 11 => expRExt_uid114_fpDivTest_b(10)) & expRExt_uid114_fpDivTest_b) & '0');
    expOvf_uid118_fpDivTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("0" & "0000" & cstAllOWE_uid18_fpDivTest_q) & expOvf_uid118_fpDivTest_cin(0));
    expOvf_uid118_fpDivTest: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expOvf_uid118_fpDivTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            expOvf_uid118_fpDivTest_o <= STD_LOGIC_VECTOR(SIGNED(expOvf_uid118_fpDivTest_a) - SIGNED(expOvf_uid118_fpDivTest_b));
        END IF;
    END PROCESS;
    expOvf_uid118_fpDivTest_n(0) <= not (expOvf_uid118_fpDivTest_o(13));

    -- invExpXIsMax_uid29_fpDivTest(LOGICAL,28)@14
    invExpXIsMax_uid29_fpDivTest_a <= expXIsMax_uid24_fpDivTest_q;
    invExpXIsMax_uid29_fpDivTest_q <= not (invExpXIsMax_uid29_fpDivTest_a);

    -- InvExpXIsZero_uid30_fpDivTest(LOGICAL,29)@14
    InvExpXIsZero_uid30_fpDivTest_a <= excZ_x_uid23_fpDivTest_q;
    InvExpXIsZero_uid30_fpDivTest_q <= not (InvExpXIsZero_uid30_fpDivTest_a);

    -- excR_x_uid31_fpDivTest(LOGICAL,30)@14
    excR_x_uid31_fpDivTest_a <= InvExpXIsZero_uid30_fpDivTest_q;
    excR_x_uid31_fpDivTest_b <= invExpXIsMax_uid29_fpDivTest_q;
    excR_x_uid31_fpDivTest_q <= excR_x_uid31_fpDivTest_a and excR_x_uid31_fpDivTest_b;

    -- excXRYROvf_uid125_fpDivTest(LOGICAL,124)@14
    excXRYROvf_uid125_fpDivTest_a <= excR_x_uid31_fpDivTest_q;
    excXRYROvf_uid125_fpDivTest_b <= excR_y_uid45_fpDivTest_q;
    excXRYROvf_uid125_fpDivTest_c <= expOvf_uid118_fpDivTest_n;
    excXRYROvf_uid125_fpDivTest_q <= excXRYROvf_uid125_fpDivTest_a and excXRYROvf_uid125_fpDivTest_b and excXRYROvf_uid125_fpDivTest_c;

    -- excXRYZ_uid124_fpDivTest(LOGICAL,123)@14
    excXRYZ_uid124_fpDivTest_a <= excR_x_uid31_fpDivTest_q;
    excXRYZ_uid124_fpDivTest_b <= excZ_y_uid37_fpDivTest_q;
    excXRYZ_uid124_fpDivTest_q <= excXRYZ_uid124_fpDivTest_a and excXRYZ_uid124_fpDivTest_b;

    -- excRInf_uid128_fpDivTest(LOGICAL,127)@14
    excRInf_uid128_fpDivTest_a <= excXRYZ_uid124_fpDivTest_q;
    excRInf_uid128_fpDivTest_b <= excXRYROvf_uid125_fpDivTest_q;
    excRInf_uid128_fpDivTest_c <= excXIYZ_uid126_fpDivTest_q;
    excRInf_uid128_fpDivTest_d <= excXIYR_uid127_fpDivTest_q;
    excRInf_uid128_fpDivTest_q <= excRInf_uid128_fpDivTest_a or excRInf_uid128_fpDivTest_b or excRInf_uid128_fpDivTest_c or excRInf_uid128_fpDivTest_d;

    -- xRegOrZero_uid121_fpDivTest(LOGICAL,120)@14
    xRegOrZero_uid121_fpDivTest_a <= excR_x_uid31_fpDivTest_q;
    xRegOrZero_uid121_fpDivTest_b <= excZ_x_uid23_fpDivTest_q;
    xRegOrZero_uid121_fpDivTest_q <= xRegOrZero_uid121_fpDivTest_a or xRegOrZero_uid121_fpDivTest_b;

    -- regOrZeroOverInf_uid122_fpDivTest(LOGICAL,121)@14
    regOrZeroOverInf_uid122_fpDivTest_a <= xRegOrZero_uid121_fpDivTest_q;
    regOrZeroOverInf_uid122_fpDivTest_b <= excI_y_uid41_fpDivTest_q;
    regOrZeroOverInf_uid122_fpDivTest_q <= regOrZeroOverInf_uid122_fpDivTest_a and regOrZeroOverInf_uid122_fpDivTest_b;

    -- expUdf_uid115_fpDivTest(COMPARE,114)@13
    expUdf_uid115_fpDivTest_cin <= GND_q;
    expUdf_uid115_fpDivTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("0" & "00000000000" & GND_q) & '0');
    expUdf_uid115_fpDivTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 11 => expRExt_uid114_fpDivTest_b(10)) & expRExt_uid114_fpDivTest_b) & expUdf_uid115_fpDivTest_cin(0));
    expUdf_uid115_fpDivTest: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expUdf_uid115_fpDivTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            expUdf_uid115_fpDivTest_o <= STD_LOGIC_VECTOR(SIGNED(expUdf_uid115_fpDivTest_a) - SIGNED(expUdf_uid115_fpDivTest_b));
        END IF;
    END PROCESS;
    expUdf_uid115_fpDivTest_n(0) <= not (expUdf_uid115_fpDivTest_o(13));

    -- regOverRegWithUf_uid120_fpDivTest(LOGICAL,119)@14
    regOverRegWithUf_uid120_fpDivTest_a <= expUdf_uid115_fpDivTest_n;
    regOverRegWithUf_uid120_fpDivTest_b <= excR_x_uid31_fpDivTest_q;
    regOverRegWithUf_uid120_fpDivTest_c <= excR_y_uid45_fpDivTest_q;
    regOverRegWithUf_uid120_fpDivTest_q <= regOverRegWithUf_uid120_fpDivTest_a and regOverRegWithUf_uid120_fpDivTest_b and regOverRegWithUf_uid120_fpDivTest_c;

    -- zeroOverReg_uid119_fpDivTest(LOGICAL,118)@14
    zeroOverReg_uid119_fpDivTest_a <= excZ_x_uid23_fpDivTest_q;
    zeroOverReg_uid119_fpDivTest_b <= excR_y_uid45_fpDivTest_q;
    zeroOverReg_uid119_fpDivTest_q <= zeroOverReg_uid119_fpDivTest_a and zeroOverReg_uid119_fpDivTest_b;

    -- excRZero_uid123_fpDivTest(LOGICAL,122)@14
    excRZero_uid123_fpDivTest_a <= zeroOverReg_uid119_fpDivTest_q;
    excRZero_uid123_fpDivTest_b <= regOverRegWithUf_uid120_fpDivTest_q;
    excRZero_uid123_fpDivTest_c <= regOrZeroOverInf_uid122_fpDivTest_q;
    excRZero_uid123_fpDivTest_q <= excRZero_uid123_fpDivTest_a or excRZero_uid123_fpDivTest_b or excRZero_uid123_fpDivTest_c;

    -- concExc_uid132_fpDivTest(BITJOIN,131)@14
    concExc_uid132_fpDivTest_q <= excRNaN_uid131_fpDivTest_q & excRInf_uid128_fpDivTest_q & excRZero_uid123_fpDivTest_q;

    -- redist7(DELAY,197)
    redist7 : dspba_delay
    GENERIC MAP ( width => 3, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => concExc_uid132_fpDivTest_q, xout => redist7_q, clk => clk, aclr => areset );

    -- excREnc_uid133_fpDivTest(LOOKUP,132)@15
    excREnc_uid133_fpDivTest: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            excREnc_uid133_fpDivTest_q <= "01";
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (redist7_q) IS
                WHEN "000" => excREnc_uid133_fpDivTest_q <= "01";
                WHEN "001" => excREnc_uid133_fpDivTest_q <= "00";
                WHEN "010" => excREnc_uid133_fpDivTest_q <= "10";
                WHEN "011" => excREnc_uid133_fpDivTest_q <= "00";
                WHEN "100" => excREnc_uid133_fpDivTest_q <= "11";
                WHEN "101" => excREnc_uid133_fpDivTest_q <= "00";
                WHEN "110" => excREnc_uid133_fpDivTest_q <= "00";
                WHEN "111" => excREnc_uid133_fpDivTest_q <= "00";
                WHEN OTHERS => -- unreachable
                               excREnc_uid133_fpDivTest_q <= (others => '-');
            END CASE;
        END IF;
    END PROCESS;

    -- redist5(DELAY,195)
    redist5 : dspba_delay
    GENERIC MAP ( width => 2, depth => 3, reset_kind => "ASYNC" )
    PORT MAP ( xin => excREnc_uid133_fpDivTest_q, xout => redist5_q, clk => clk, aclr => areset );

    -- redist6(DELAY,196)
    redist6 : dspba_delay
    GENERIC MAP ( width => 2, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist5_q, xout => redist6_q, clk => clk, aclr => areset );

    -- expRPostExc_uid141_fpDivTest(MUX,140)@20
    expRPostExc_uid141_fpDivTest_s <= redist6_q;
    expRPostExc_uid141_fpDivTest: PROCESS (expRPostExc_uid141_fpDivTest_s, cstAllZWE_uid20_fpDivTest_q, expRPreExc_uid112_fpDivTest_q, cstAllOWE_uid18_fpDivTest_q)
    BEGIN
        CASE (expRPostExc_uid141_fpDivTest_s) IS
            WHEN "00" => expRPostExc_uid141_fpDivTest_q <= cstAllZWE_uid20_fpDivTest_q;
            WHEN "01" => expRPostExc_uid141_fpDivTest_q <= expRPreExc_uid112_fpDivTest_q;
            WHEN "10" => expRPostExc_uid141_fpDivTest_q <= cstAllOWE_uid18_fpDivTest_q;
            WHEN "11" => expRPostExc_uid141_fpDivTest_q <= cstAllOWE_uid18_fpDivTest_q;
            WHEN OTHERS => expRPostExc_uid141_fpDivTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- oneFracRPostExc2_uid134_fpDivTest(CONSTANT,133)
    oneFracRPostExc2_uid134_fpDivTest_q <= "00000000000000000000001";

    -- fracPostRndFPostUlp_uid106_fpDivTest(BITSELECT,105)@19
    fracPostRndFPostUlp_uid106_fpDivTest_in <= fracRPreExcExt_uid105_fpDivTest_q(22 downto 0);
    fracPostRndFPostUlp_uid106_fpDivTest_b <= fracPostRndFPostUlp_uid106_fpDivTest_in(22 downto 0);

    -- redist9(DELAY,199)
    redist9 : dspba_delay
    GENERIC MAP ( width => 23, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist8_outputreg_q, xout => redist9_q, clk => clk, aclr => areset );

    -- fracRPreExc_uid107_fpDivTest(MUX,106)@19
    fracRPreExc_uid107_fpDivTest_s <= redist10_q;
    fracRPreExc_uid107_fpDivTest: PROCESS (fracRPreExc_uid107_fpDivTest_s, redist9_q, fracPostRndFPostUlp_uid106_fpDivTest_b)
    BEGIN
        CASE (fracRPreExc_uid107_fpDivTest_s) IS
            WHEN "0" => fracRPreExc_uid107_fpDivTest_q <= redist9_q;
            WHEN "1" => fracRPreExc_uid107_fpDivTest_q <= fracPostRndFPostUlp_uid106_fpDivTest_b;
            WHEN OTHERS => fracRPreExc_uid107_fpDivTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- fracRPostExc_uid137_fpDivTest(MUX,136)@19
    fracRPostExc_uid137_fpDivTest_s <= redist5_q;
    fracRPostExc_uid137_fpDivTest: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            fracRPostExc_uid137_fpDivTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (fracRPostExc_uid137_fpDivTest_s) IS
                WHEN "00" => fracRPostExc_uid137_fpDivTest_q <= paddingY_uid15_fpDivTest_q;
                WHEN "01" => fracRPostExc_uid137_fpDivTest_q <= fracRPreExc_uid107_fpDivTest_q;
                WHEN "10" => fracRPostExc_uid137_fpDivTest_q <= paddingY_uid15_fpDivTest_q;
                WHEN "11" => fracRPostExc_uid137_fpDivTest_q <= oneFracRPostExc2_uid134_fpDivTest_q;
                WHEN OTHERS => fracRPostExc_uid137_fpDivTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- divR_uid144_fpDivTest(BITJOIN,143)@20
    divR_uid144_fpDivTest_q <= redist4_q & expRPostExc_uid141_fpDivTest_q & fracRPostExc_uid137_fpDivTest_q;

    -- xOut(GPOUT,4)@20
    q <= divR_uid144_fpDivTest_q;

END normal;
