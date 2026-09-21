library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity u_rx is
    generic(
        width        : integer;
        no_of_sample : integer 
    );
    port(
        --inputs
        clk           : in std_logic;
        data_in       : in std_logic;
        baud_en_rx    : in std_logic;

        --outputs 
        data_out      : out std_logic_vector(width - 1 downto 0);
        rx_active     : out std_logic;
        rx_data_ready : out std_logic := '0'
    );
end entity u_rx;

architecture behav of u_rx is

    type StateType is (idle, wait_mid_of_start_bit, receive_data, receive_stop_bit);
    signal State: StateType := idle;

    signal bit_index    : integer range 0 to width - 1 := 0;
    signal data_buf     : std_logic_vector(width - 1 downto 0) := "00000000";
    signal pulse        : integer range 0 to no_of_sample - 1 := 0;
    signal data_in_ff_1 : std_logic := '1';
    signal data_in_ff_2 : std_logic := '1';

    attribute ASYNC_REG : string;
    attribute ASYNC_REG of data_in_ff_1, data_in_ff_2 : signal is "TRUE";
begin

pr_uart_rx : process (clk) begin

    if rising_edge(clk) then

    data_in_ff_1 <= data_in;
    data_in_ff_2 <= data_in_ff_1;

        case State is 

            when idle =>
                rx_data_ready <= '0';
                pulse     <= 0;
                if data_in_ff_2 = '1' then
                    State <= idle;
                    rx_active <= '0';
                else
                    rx_active <= '1';
                    State <= wait_mid_of_start_bit;
                end if;
                
            when wait_mid_of_start_bit =>
            rx_active <= '1'; 
                if baud_en_rx = '1' then
                    if pulse = (no_of_sample / 2) - 1 then
                            if data_in_ff_2 = '1' then 
                                rx_active <= '0';
                                State <= idle;
                            else
                                pulse <= 0;
                                State <= receive_data;
                            end if;
                    else
                        pulse <= pulse + 1;
                    end if;
                    
                end if;

            when receive_data => 
                rx_active <= '1';
                if baud_en_rx = '1' then
                    if pulse = no_of_sample - 1 then
                        data_buf <= data_in_ff_2 & data_buf(width - 1 downto 1);
                    end if;
                    if pulse = no_of_sample - 1 then
                        pulse <= 0;
                        if bit_index = width - 1 then
                            bit_index <= 0;
                            State     <= receive_stop_bit;
                        else
                            bit_index <= bit_index + 1;
                        end if;
                    else
                        pulse <= pulse + 1;
                    end if;
                end if;

            when receive_stop_bit =>
                rx_active <= '1';
                if baud_en_rx = '1' then
                    if pulse = no_of_sample - 1 then
                        pulse         <= 0;
                        if data_in_ff_2  = '1' then 
                            rx_data_ready <= '1';
                            data_out      <= data_buf;
                        end if;
                        rx_active <= '0';
                        State     <= idle;
                    else
                        pulse <= pulse + 1;
                    end if;
                end if;

            when others =>
                State     <= idle;
                pulse     <= 0;
                rx_active <='0';
                bit_index <= 0;
        end case;
    end if;
end process pr_uart_rx;

end architecture behav;