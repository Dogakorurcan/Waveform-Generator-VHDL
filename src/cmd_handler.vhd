library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.wave_gen_pkg.all;

entity cmd_handler is

    port(
        --inputs
        clk            : in std_logic;
        rx_data_ready  : in std_logic := '0';
        rx_data        : in std_logic_vector(7 downto 0) := "00000000";
        tx_active      : in std_logic := '0';
        sw             : in std_logic_vector(2 downto 0) := "111";

        --outputs
        cmd_ready      : out std_logic := '1';
        cmd            : out std_logic_vector(15 downto 0) := "0100000100110000";
        tx_send        : out std_logic := '0';
        tx_data        : out std_logic_vector(7 downto 0) := "00000000"
    );

end entity cmd_handler;

architecture Behave of cmd_handler is

    signal flag : std_logic := '0';

    type StateType is (idle, write_version, write_baudrate);
    signal State        : StateType := idle;
    signal index        : integer range 0 to 15 := 0;
    signal sw_latch     : std_logic_vector(2 downto 0) := "111";
    signal tx_send_step : integer range 0 to 2 := 0;
    signal sw_ff_1   : std_logic_vector(2 downto 0) := "111";
    signal sw_ff_2   : std_logic_vector(2 downto 0) := "111";
    attribute ASYNC_REG : string;
    attribute ASYNC_REG of sw_ff_1, sw_ff_2 : signal is "TRUE";
begin

pr_cmd: process (clk) begin

    if rising_edge(clk) then
    sw_ff_1  <= sw;
    sw_ff_2  <= sw_ff_1;
    
            case State is

                when idle =>

                    if rx_data_ready = '1' then

                        case rx_data is
                          
                                when CMD_lower_a =>  -- a
                                cmd_ready <= '0';
                                    if flag = '1' then
                                        State <= idle;
                                    else
                                        State <= write_version;
                                    end if;

                                when CMD_lower_b =>  -- b
                                cmd_ready <= '0';
                                    if flag = '1' then
                                        State <= idle;
                                    else
                                        State <= write_baudrate;
                                        sw_latch <= sw_ff_2;
                                    end if;

                                when CMD_A | CMD_B | CMD_C | CMD_D =>  -- Wave type
                                cmd_ready <= '0';
                                    if flag = '1' then
                                        State <= idle;
                                    else
                                        cmd(15 downto 8) <= rx_data;
                                        flag  <= '1';
                                        State <= idle;
                                    end if;

                                when CMD_0 | CMD_1 | CMD_2 | CMD_3 | CMD_4 | CMD_5 | CMD_6 | CMD_7 | CMD_8 | CMD_9 =>  --Frequency selection
                                    if flag = '1' then
                                        cmd(7 downto 0) <= rx_data;
                                        flag  <= '0';
                                        State <= idle;
                                        cmd_ready <= '1';
                                    end if;

                                when others =>
                                    State <= idle;
                                    cmd_ready <= '0';
                                   
                        end case;
                    else
                        cmd_ready <= '0'; 
                    end if;

                when write_version =>  
                cmd_ready <= '0';

                case tx_send_step is

                    when 0 =>

                        if index < VERSION_PRINT'length then 
                            tx_data <= VERSION_PRINT(index);
                            index <= index + 1;
                            tx_send <= '1';
                            tx_send_step <= 1;
                        else
                            index <= 0;
                            State <= idle;
                            tx_send <= '0';
                        end if;

                    when 1 =>
                        tx_send <= '0';
                        if tx_active = '1' then
                            tx_send_step <= 2;
                        end if;

                    when 2 =>
                        if tx_active = '0' then
                            tx_send_step <= 0;
                            
                        end if;

                    when others =>
                        tx_send_step <= 0;
                        tx_send <= '0';

                    end case;



                when write_baudrate =>
                cmd_ready <= '0';
                    
                    case tx_send_step is

                        when 0 =>

                        case sw_latch is

                            when "000" => 
                                if index < BAUDRATE_PRINT_4800'length then 
                                    tx_data <= BAUDRATE_PRINT_4800(index);
                                    index   <= index + 1;
                                    tx_send <= '1';
                                    tx_send_step <= 1;
                                else
                                    index <= 0;
                                    State <= idle;
                                    tx_send <= '0';
                                end if;

                            when "001" => 
                                if index < BAUDRATE_PRINT_9600'length then 
                                    tx_data <= BAUDRATE_PRINT_9600(index);
                                    index   <= index + 1;
                                    tx_send <= '1';
                                    tx_send_step <= 1;
                                else
                                    index <= 0;
                                    State <= idle;
                                    tx_send <= '0';
                                end if;

                            when "010" =>
                                if index < BAUDRATE_PRINT_19200'length then 
                                    tx_data <= BAUDRATE_PRINT_19200(index);
                                    index   <= index + 1;
                                    tx_send <= '1';
                                    tx_send_step <= 1;
                                else
                                    index <= 0;
                                    State <= idle;
                                    tx_send <= '0';
                                end if;
                                
                            when "011" =>
                                if index < BAUDRATE_PRINT_38400'length then 
                                    tx_data <= BAUDRATE_PRINT_38400(index);
                                    index   <= index + 1;
                                    tx_send <= '1';
                                    tx_send_step <= 1;
                                else
                                    index <= 0;
                                    State <= idle;
                                    tx_send <= '0';
                                end if;
                                
                            when "100" =>
                                if index < BAUDRATE_PRINT_57600'length then 
                                    tx_data <= BAUDRATE_PRINT_57600(index);
                                    index   <= index + 1;
                                    tx_send <= '1';
                                    tx_send_step <= 1;
                                else
                                    index <= 0;
                                    State <= idle;
                                    tx_send <= '0';
                                end if;
                                
                            when "101" =>
                                if index < BAUDRATE_PRINT_115200'length then 
                                    tx_data <= BAUDRATE_PRINT_115200(index);
                                    index   <= index + 1;
                                    tx_send <= '1';
                                    tx_send_step <= 1;
                                else
                                    index <= 0;
                                    State <= idle;
                                    tx_send <= '0';
                                end if;
                                
                            when "110" =>
                                if index < BAUDRATE_PRINT_230400'length then 
                                    tx_data <= BAUDRATE_PRINT_230400(index);
                                    index   <= index + 1;
                                    tx_send <= '1';
                                    tx_send_step <= 1;
                                else
                                    index <= 0;
                                    State <= idle;
                                    tx_send <= '0';
                                end if;
                                
                            when "111" =>
                                if index < BAUDRATE_PRINT_460800'length then 
                                    tx_data <= BAUDRATE_PRINT_460800(index);
                                    index   <= index + 1;
                                    tx_send <= '1';
                                    tx_send_step <= 1;
                                else
                                    index <= 0;
                                    State <= idle;
                                    tx_send <= '0';
                                end if;                            

                            when others =>
                                State <= idle;
                                tx_send <= '0';
                        end case;

                    when 1 =>
                        tx_send <= '0';
                        if tx_active = '1' then
                            tx_send_step <= 2;
                        end if;

                    when 2 =>
                        if tx_active = '0' then
                            tx_send_step <= 0;
                            
                        end if;

                    when others =>
                    tx_send_step <= 0;
                    index <= 0;
                    end case;

            when others =>
                State   <= idle;
                tx_send <= '0';
                index   <= 0;
            end case;

    end if;


end process pr_cmd;



end architecture Behave;