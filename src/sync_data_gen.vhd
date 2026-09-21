library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.wave_gen_pkg.all;

entity sync_data_gen is
    port (
        --inputs
        clk       : in std_logic;
        en        : in std_logic;
        edge_low  : in std_logic;
        wave      : in std_logic_vector(7 downto 0);

        --outputs
        sync      : out std_logic := '1'; 
        dac_data  : out std_logic := '0'
    );
end entity sync_data_gen;

architecture Behave of sync_data_gen is

    signal dac_data_reg : std_logic_vector(15 downto 0) := x"0000";
    signal bit_count    : integer range 0 to 16 := 0;
    type StateType is (idle, active);
    signal State: StateType := idle;

begin

    pr_sync_data_gen: process (clk) begin

            if rising_edge(clk) then
                
                    case State is

                        when idle =>
                            sync <= '1';
                            if en = '1' then
                                dac_data_reg <= control_bits & wave;
                                bit_count <= 0;
                                State <= active;
                            else
                                dac_data <= '0';
                                State <= idle;
                            end if;
                            
                        when active =>

                            if edge_low = '1' then

                                if bit_count <= 15 then
                                    dac_data <= dac_data_reg(15);
                                    dac_data_reg <= dac_data_reg(14 downto 0) & '0';
                                    bit_count <= bit_count + 1;
                                    sync <= '0';
                                else
                                    bit_count <= 0;
                                    State <= idle;                                   
                                    sync <= '1';                                
                                end if;

                            end if;
                        when others =>
                            State     <= idle;
                            sync      <= '1';
                            dac_data  <= '0';
                            bit_count <= 0;
                    end case;
                
            end if;

    end process pr_sync_data_gen;

end architecture Behave;