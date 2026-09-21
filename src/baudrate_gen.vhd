library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity baudrate_gen is
    generic(
        osc_freq     : integer;
        no_of_sample : integer
    );
    port(
        --inputs
        clk       : in std_logic;
        sw        : in std_logic_vector(2 downto 0) := "111";
        rx_active : in std_logic := '0';
        tx_active : in std_logic := '0';

        --outputs
        baud_en_rx : out std_logic;
        baud_en_tx : out std_logic
    );
end entity baudrate_gen;

architecture behav of baudrate_gen is 
    signal tx_count  : integer range 0 to 2047 := 54;
    signal rx_count  : integer range 0 to 2047 := 54;
    signal max_count : integer range 0 to 2047 := 0;
    signal sw_ff_1   : std_logic_vector(2 downto 0) := "111";
    signal sw_ff_2   : std_logic_vector(2 downto 0) := "111";
    attribute ASYNC_REG : string;
    attribute ASYNC_REG of sw_ff_1, sw_ff_2 : signal is "TRUE";
begin

process(clk)
begin
    if rising_edge(clk) then
        
    sw_ff_1 <= sw;
    sw_ff_2 <= sw_ff_1;

        case sw_ff_2 is
            when "000"  => max_count <= osc_freq / (4800 * no_of_sample); 
            when "001"  => max_count <= osc_freq / (9600 * no_of_sample);
            when "010"  => max_count <= osc_freq / (19200 * no_of_sample);
            when "011"  => max_count <= osc_freq / (38400 * no_of_sample);
            when "100"  => max_count <= osc_freq / (57600 * no_of_sample);
            when "101"  => max_count <= osc_freq / (115200 * no_of_sample);
            when "110"  => max_count <= osc_freq / (230400 * no_of_sample);
            when "111"  => max_count <= osc_freq / (460800 * no_of_sample);
            when others => max_count <= osc_freq / (115200 * no_of_sample); 
        end case;

    end if;
end process;

    pr_tx_baud : process (clk)
    begin
        if rising_edge(clk) then
            if tx_active    = '0' then
                tx_count   <=  0;
                baud_en_tx <= '0';
                elsif tx_count >= max_count - 1 then
                    tx_count   <= 0;
                    baud_en_tx <= '1';
                else
                    tx_count <= tx_count + 1;
                    baud_en_tx <= '0';
            end if;       
        end if;
    end process pr_tx_baud;

    pr_rx_baud : process (clk)
    begin
        if rising_edge(clk) then
            if rx_active    = '0' then
                rx_count   <=  0;
                baud_en_rx <= '0';
                elsif rx_count >= max_count - 1 then
                    rx_count   <= 0;
                    baud_en_rx <= '1';
                else
                    rx_count <= rx_count + 1;
                    baud_en_rx <= '0';
                
            end if;       
        end if;
    end process pr_rx_baud;

end architecture behav;


