library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package tb_pkg is

    type byte_array is array (natural range<>) of std_logic_vector(7 downto 0);

    constant baud_period_460800 : time := 2170 ns;
    constant baud_period_230400 : time := 4340 ns;
    constant baud_period_115200 : time := 8680 ns;
    constant baud_period_57600  : time := 17361 ns;
    constant baud_period_38400  : time := 26041 ns;
    constant baud_period_19200  : time := 52083 ns;
    constant baud_period_9600   : time := 104166 ns;
    constant baud_period_4800   : time := 208333 ns;

    constant baudrate_460800    :std_logic_vector(2 downto 0) := "111";
    constant baudrate_230400    :std_logic_vector(2 downto 0) := "110";
    constant baudrate_115200    :std_logic_vector(2 downto 0) := "101";
    constant baudrate_57600     :std_logic_vector(2 downto 0) := "100";
    constant baudrate_38400     :std_logic_vector(2 downto 0) := "011";
    constant baudrate_19200     :std_logic_vector(2 downto 0) := "010";
    constant baudrate_9600      :std_logic_vector(2 downto 0) := "001";
    constant baudrate_4800      :std_logic_vector(2 downto 0) := "000";

    -- arrays that used in loop tests
    constant frequency : byte_array :=(
    x"30", --390hz
    x"31", --434hz
    x"32", --488hz
    x"33", --558hz
    x"34", --651hz
    x"35", --781hz
    x"36", --976hz
    x"37", --1.3khz
    x"38", --1.953khz
    x"39"  --3.9khz
    );

    constant wave_type_hex : byte_array :=(
    x"41", --A (sawtooth)
    x"42", --B (square)
    x"43", --C (triangle)
    x"44"  --D (sine)
    );

    type real_array is array (natural range <>) of real;
    -- possible frequency array that tested in the loop
    constant expected_freq_loop_1 : real_array := (
    390.0,
    434.0,
    488.0,
    558.0,
    651.0,
    781.0,
    976.0,
    1300.0,
    1953.0,
    3900.0
    );

    
    constant expected_freq_loop_2 : real_array := (
    3900.0,-- change this to the last frequency value before the frequency test loop, otherwise dont touch this array.
    390.0,
    434.0,
    488.0,
    558.0,
    651.0,
    781.0,
    976.0,
    1300.0,
    1953.0
    );





end package tb_pkg;