library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.wave_gen_pkg.all;

entity en_gen is
    port (
        --inputs
        clk     : in std_logic;
        cmd_rdy : in std_logic := '1';
        freq    : in std_logic_vector(7 downto 0) := "00110000" ; -- cmd(7 downto 0) from cmd_handler

        --output
        en_out  : out std_logic
    );
    
end entity en_gen;

architecture Behave of en_gen is

    signal counter : integer range 0 to 1000 := 0;
    signal active_freq : std_logic_vector(7 downto 0);
    signal next_freq : std_logic_vector(7 downto 0);

begin

    pr_en_gen: process (clk) begin

        if rising_edge(clk) then

            if cmd_rdy = '1' then
                next_freq <= freq;
            end if;

                case active_freq is

                    when CMD_0 => -- 0 -> counter limit 1000 -> freq 390
                        if counter >= count_1000 - 1 then
                            counter <= 0;
                            en_out <= '1';
                            active_freq <= next_freq;
                        else
                            counter <= counter + 1;
                            en_out <= '0';
                        end if;

                    when CMD_1 => -- 1 -> counter limit 900 -> freq 434
                        if counter >= count_900 - 1 then
                            counter <= 0;
                            en_out <= '1';
                            active_freq <= next_freq;
                        else
                            counter <= counter + 1;
                            en_out <= '0';                            
                        end if;
                    
                    when CMD_2 => -- 2 -> counter limit 800 -> freq 488
                        if counter >= count_800 - 1 then
                            counter <= 0;
                            en_out <= '1';
                            active_freq <= next_freq;
                        else
                            counter <= counter + 1;
                            en_out <= '0';
                        end if;

                    when CMD_3 => -- 3 -> counter limit 700 -> freq 558
                        if counter >= count_700 - 1 then
                            counter <= 0;
                            en_out <= '1';
                            active_freq <= next_freq;
                        else
                            counter <= counter + 1;
                            en_out <= '0';
                        end if;

                    when CMD_4 => -- 4 -> counter limit 600 -> freq 651
                        if counter >= count_600 - 1 then
                            counter <= 0;
                            en_out <= '1';
                            active_freq <= next_freq;
                        else
                            counter <= counter + 1;
                            en_out <= '0';
                        end if;   

                    when CMD_5 => -- 5 -> counter limit 500 -> freq 781
                        if counter >= count_500 - 1 then
                            counter <= 0;
                            en_out <= '1';
                            active_freq <= next_freq;
                        else
                            counter <= counter + 1;
                            en_out <= '0';
                        end if; 

                    when CMD_6 => -- 6 -> counter limit 400 -> freq 976 
                        if counter >= count_400 - 1 then
                            counter <= 0;
                            en_out <= '1';
                            active_freq <= next_freq;
                        else
                            counter <= counter + 1;
                            en_out <= '0';
                        end if;                    
                    
                    when CMD_7 => -- 7 -> counter limit 300 -> freq 1300  
                        if counter >= count_300 - 1 then
                            counter <= 0;
                            en_out <= '1';
                            active_freq <= next_freq;
                        else
                            counter <= counter + 1;
                            en_out <= '0';
                        end if; 
                    
                    when CMD_8 => -- 8 -> counter limit 200 -> freq 1953
                        if counter >= count_200 - 1 then
                            counter <= 0;
                            en_out <= '1';
                            active_freq <= next_freq;
                        else
                            counter <= counter + 1;
                            en_out <= '0';
                        end if; 
                    
                    when CMD_9 => -- 9 -> counter limit 100 -> freq 3900               
                        if counter >= count_100 - 1 then
                            counter <= 0;
                            en_out <= '1';
                            active_freq <= next_freq;
                        else
                            counter <= counter + 1;
                            en_out <= '0';
                        end if; 

                    when others =>
                        counter <= 0;
                        en_out <= '0';
                        if cmd_rdy ='1' then
                            active_freq <= freq;
                        end if;
                end case;

            end if;
            
    end process pr_en_gen;

end architecture Behave;