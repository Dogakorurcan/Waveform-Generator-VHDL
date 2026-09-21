library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity u_tx is
    generic(
        width        : integer;
        no_of_sample : integer
    );
    port(
        --inputs
        clk        : in std_logic;
        tx_send    : in std_logic;
        data_in    : in std_logic_vector(width - 1 downto 0) := "00000000";
        baud_en_tx : in std_logic;

        --outputs
        tx_data_out : out std_logic := '1';
        tx_active   : out std_logic
    );
end entity u_tx;

architecture behav of u_tx is

    type StateType is (idle, send_start_bit, send_data, send_stop_bit);
    signal State: StateType := idle;

    signal bit_index : integer range 0 to width - 1 := 0;
    signal data_buf  : std_logic_vector(width - 1 downto 0) := "00000000";
    signal pulse     : integer range 0 to no_of_sample - 1 := 0;
    
begin

pr_uart_tx : process (clk) begin

    if rising_edge(clk) then
        case State is
            when idle =>
                tx_active   <= '0';
                tx_data_out <= '1';
                bit_index   <= 0;
                pulse       <= 0;
                if tx_send = '1' then
                    State <= send_start_bit;
                    tx_active   <= '1';
                    data_buf <= data_in;
                else         
                    State <= idle;
                end if;
            when send_start_bit =>
                tx_data_out <= '0';
                tx_active   <= '1';
                if baud_en_tx = '1' then
                    if pulse = no_of_sample - 1 then
                        pulse <= 0;
                        State <= send_data;
                    else
                        pulse <= pulse +1;
                    end if;
                end if;
            when send_data =>
                tx_data_out <= data_buf(0);
                tx_active   <= '1';
                if baud_en_tx = '1' then
                    if pulse = no_of_sample - 1 then
                        pulse <= 0;
                        if bit_index = width - 1 then
                            bit_index <= 0;
                            State     <= send_stop_bit;
                        else 
                            data_buf <= '0' & data_buf(width - 1 downto 1);
                            bit_index <= bit_index + 1;
                        end if;
                    else 
                        pulse <= pulse + 1;
                    end if;
                end if;
            when send_stop_bit =>
                tx_active   <= '1';
                tx_data_out <= '1';
                data_buf    <= "00000000";
                if baud_en_tx = '1' then
                    if pulse = no_of_sample - 1 then
                        pulse <= 0;
                        State <= idle;
                        tx_active <= '0';
                    else
                    pulse <= pulse +1;
                    end if;
                end if;
            when others =>
                tx_active   <= '0';
                tx_data_out <= '1';
                bit_index   <= 0;
                pulse       <= 0;   
                state       <= idle;
        end case;
    end if;
end process;

end architecture behav;


