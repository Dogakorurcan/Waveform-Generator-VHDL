library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package wave_gen_pkg is 

    --CMD_HANDLER
    type byte_array is array (natural range<>) of std_logic_vector(7 downto 0);

    constant VERSION_PRINT : byte_array(0 to 13) := (x"45", x"4C", x"45", x"43", x"54", x"52", x"41", x"49", x"43", x"5F", x"56", x"31", x"0D", x"0A");
    constant BAUDRATE_PRINT_4800  : byte_array(0 to 5) := (x"34", x"38", x"30", x"30", x"0D", x"0A");
    constant BAUDRATE_PRINT_9600  : byte_array(0 to 5) := (x"39", x"36", x"30", x"30", x"0D", x"0A");
    constant BAUDRATE_PRINT_19200 : byte_array(0 to 6) := (x"31", x"39", x"32", x"30", x"30", x"0D", x"0A");
    constant BAUDRATE_PRINT_38400 : byte_array(0 to 6) := (x"33", x"38", x"34", x"30", x"30", x"0D", x"0A");
    constant BAUDRATE_PRINT_57600 : byte_array(0 to 6) := (x"35", x"37", x"36", x"30", x"30", x"0D", x"0A");
    constant BAUDRATE_PRINT_115200: byte_array(0 to 7) := (x"31", x"31", x"35", x"32", x"30", x"30", x"0D", x"0A");
    constant BAUDRATE_PRINT_230400: byte_array(0 to 7) := (x"32", x"33", x"30", x"34", x"30", x"30", x"0D", x"0A");
    constant BAUDRATE_PRINT_460800: byte_array(0 to 7) := (x"34", x"36", x"30", x"38", x"30", x"30", x"0D", x"0A");

    constant CMD_A       : std_logic_vector(7 downto 0) := x"41";
    constant CMD_B       : std_logic_vector(7 downto 0) := x"42";
    constant CMD_C       : std_logic_vector(7 downto 0) := x"43";
    constant CMD_D       : std_logic_vector(7 downto 0) := x"44";
    constant CMD_lower_a : std_logic_vector(7 downto 0) := x"61";
    constant CMD_lower_b : std_logic_vector(7 downto 0) := x"62";
    constant CMD_0       : std_logic_vector(7 downto 0) := x"30";
    constant CMD_1       : std_logic_vector(7 downto 0) := x"31";
    constant CMD_2       : std_logic_vector(7 downto 0) := x"32";
    constant CMD_3       : std_logic_vector(7 downto 0) := x"33";
    constant CMD_4       : std_logic_vector(7 downto 0) := x"34";
    constant CMD_5       : std_logic_vector(7 downto 0) := x"35";
    constant CMD_6       : std_logic_vector(7 downto 0) := x"36";
    constant CMD_7       : std_logic_vector(7 downto 0) := x"37";
    constant CMD_8       : std_logic_vector(7 downto 0) := x"38";
    constant CMD_9       : std_logic_vector(7 downto 0) := x"39";

    constant CMD_list : byte_array(0 to 15) :=(
    CMD_A,      
    CMD_B,      
    CMD_C,      
    CMD_D,      
    CMD_lower_a,
    CMD_lower_b,
    CMD_0,      
    CMD_1,      
    CMD_2,      
    CMD_3,      
    CMD_4,      
    CMD_5,      
    CMD_6,      
    CMD_7,      
    CMD_8,      
    CMD_9      
    );


    --EN_GEN
    constant count_1000 : integer := 1000;
    constant count_900  : integer := 900;
    constant count_800  : integer := 800;
    constant count_700  : integer := 700;
    constant count_600  : integer := 600;
    constant count_500  : integer := 500;
    constant count_400  : integer := 400;
    constant count_300  : integer := 300;
    constant count_200  : integer := 200;
    constant count_100  : integer := 100;


    --WAVE_GEN
    type memory_type is array (0 to 255) of integer range 0 to 255;
    constant sine : memory_type :=
    (128, 131, 134, 137, 140, 143, 146, 149,
    152, 156, 159, 162, 165, 168, 171, 174,
    176, 179, 182, 185, 188, 191, 193, 196,
    199, 201, 204, 206, 209, 211, 213, 216,
    218, 220, 222, 224, 226, 228, 230, 232,
    234, 235, 237, 239, 240, 242, 243, 244,
    246, 247, 248, 249, 250, 251, 251, 252,
    253, 253, 254, 254, 254, 255, 255, 255,
    255, 255, 255, 255, 254, 254, 253, 253,
    252, 252, 251, 250, 249, 248, 247, 246,
    245, 244, 242, 241, 239, 238, 236, 235,
    233, 231, 229, 227, 225, 223, 221, 219,
    217, 215, 212, 210, 207, 205, 202, 200,
    197, 195, 192, 189, 186, 184, 181, 178,
    175, 172, 169, 166, 163, 160, 157, 154,
    151, 148, 145, 142, 138, 135, 132, 129,
    126, 123, 120, 117, 113, 110, 107, 104,
    101, 98, 95, 92, 89, 86, 83, 80,
    77, 74, 71, 69, 66, 63, 60, 58,
    55, 53, 50, 48, 45, 43, 40, 38,
    36, 34, 32, 30, 28, 26, 24, 22,
    20, 19, 17, 16, 14, 13, 11, 10,
    9, 8, 7, 6, 5, 4, 3, 3,
    2, 2, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 1, 1, 1, 2, 2,
    3, 4, 4, 5, 6, 7, 8, 9,
    11, 12, 13, 15, 16, 18, 20, 21,
    23, 25, 27, 29, 31, 33, 35, 37,
    39, 42, 44, 46, 49, 51, 54, 56,
    59, 62, 64, 67, 70, 73, 76, 79,
    81, 84, 87, 90, 93, 96, 99, 103,
    106, 109, 112, 115, 118, 121, 124, 127);  


    --SYNC_DATA_GEN
    constant control_bits : std_logic_vector(7 downto 0) := "00110000"; --Dac control bits




end package wave_gen_pkg;