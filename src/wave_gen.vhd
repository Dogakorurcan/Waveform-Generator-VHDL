library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.wave_gen_pkg.all;

entity wave_gen is
    port (
        --inputs
        clk       : in std_logic;
        en        : in std_logic;
        cmd_rdy   : in std_logic := '1';
        wave_type : in std_logic_vector(7 downto 0) := "01000001";

        --outputs
        wave_out  : out std_logic_vector(7 downto 0) := "00000000"
    );
end entity wave_gen;

architecture Behave of wave_gen is

    signal wave_buf : std_logic_vector(7 downto 0);
    signal wave_counter : unsigned(7 downto 0) := "00000000";


begin

    pr_wave_gen: process (clk) begin
        
        if rising_edge (clk) then

            if cmd_rdy = '1' then
                wave_buf <= wave_type;
                wave_counter <= "00000000"; 
            elsif en = '1' then
                

                case wave_buf is

                    when CMD_A => -- A sawtooth
                        if wave_counter = 255 then
                            wave_counter <= "00000000";
                            wave_out <= std_logic_vector(wave_counter); 
                        else
                            wave_out <= std_logic_vector(wave_counter); 
                            wave_counter <= wave_counter + 1;
                        end if;

                    when CMD_B => -- B square
                          
                            if wave_counter <= 127 then
                                wave_out <= "00000000";
                                wave_counter <= wave_counter + 1;
                            else 
                                wave_out <= "11111111";
                                wave_counter <= wave_counter + 1;
                            end if;
                        

                    when CMD_C => -- C triangle
                        
                            if unsigned(wave_counter) <= 127 then
                                wave_out <= std_logic_vector(shift_left(unsigned(wave_counter), 1));
                                wave_counter <= wave_counter + 1;
                            else
                                wave_out <= std_logic_vector(shift_left(255 - unsigned(wave_counter), 1));
                                wave_counter <= wave_counter + 1;
                            
                            end if;
                        

                    when CMD_D => -- D sine
                        if wave_counter > 255 then
                            wave_counter <= "00000000";
                        else
                            wave_out <= std_logic_vector(to_unsigned(sine(to_integer(wave_counter)), 8));
                            wave_counter <= wave_counter + 1;
                        end if;

                    when others =>
                        wave_counter <= "00000000";
                        wave_out     <= "00000000";

                end case;

            end if;

        end if;

    end process pr_wave_gen;
    
end architecture Behave;