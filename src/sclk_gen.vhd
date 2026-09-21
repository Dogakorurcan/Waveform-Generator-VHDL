library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.wave_gen_pkg.all;

entity sclk_gen is
    port (
        --inputs
        clk       : in std_logic;

        --outputs
        sclk      : out std_logic;
        edge_low  : out std_logic := '0'
    );
end entity sclk_gen;

architecture Behave of sclk_gen is

    signal count           : integer range 0 to 3 := 0;
    signal temp            : std_logic            := '0';
    signal edge_temp       : std_logic            := '0';

begin

    pr_sclk_gen: process (clk) begin

        if rising_edge(clk) then
            
            sclk <= temp;
            edge_low <= edge_temp;
            if count = 1 then
                temp <= not temp;
                count <= 0;
                if temp = '1' then
                    edge_temp <= '1';
                end if;
            else
                edge_temp <= '0';
                count <= count + 1;
            end if;
 
        end if;
    end process pr_sclk_gen;

end architecture Behave;