library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DAC_RTL_simulation_model is
    port (
        s_clk   : in std_logic;
        dac_data: in std_logic;
        sync    : in std_logic;

        v_out   : out real := 0.0
        
    );
end entity DAC_RTL_simulation_model;

architecture behave of DAC_RTL_simulation_model is

    signal dac_data_buf : std_logic_vector(15 downto 0) := x"0000";
    constant v_ref      : real := 3.3;
    signal counter      : integer range 0 to 16 := 0;

begin

    process (s_clk) begin

        if rising_edge(s_clk) then

                if sync = '0' then
                    if counter <= 15 then
                        dac_data_buf <= dac_data_buf(14 downto 0) & dac_data;
                        counter <= counter + 1;
                    else
                        counter <= 0;
                    end if;
                elsif dac_data_buf(15 downto 8) = x"30" then
                    v_out <= (real(to_integer(unsigned(dac_data_buf(7 downto 0)))) / 256.0) * v_ref;
                    counter <= 0;
                else
                    counter <= 0;
                end if;
        end if;
       

    end process;

end architecture behave;