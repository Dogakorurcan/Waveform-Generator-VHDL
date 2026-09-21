library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.wave_gen_pkg.all;
use work.tb_pkg.all;

entity tb_top_level is
end entity;

architecture sim of tb_top_level is

    signal tb_clk      : std_logic := '0';
    signal tb_uart_din : std_logic := '1';
    signal tb_sw       : std_logic_vector(2 downto 0) := baudrate_460800; -- change this for desired baud rate

    signal tb_uart_dout   : std_logic;
    signal tb_sync        : std_logic;    
    signal tb_dac_data    : std_logic;
    signal tb_s_clk       : std_logic; 
    signal tb_led         : std_logic_vector(7 downto 0);
    signal tb_v_out       : real;

    constant CLK_PERIOD : time := 10 ns; --100mhz clock

    signal expected_freq : real := 0.0;
    constant tolerance_percentage : real := 0.01; -- 1% frequency tolerance


    signal check_enable : boolean := false;



begin

    UUT: entity work.wave_gen_top
        generic map(
            osc_freq     => 100000000,
            width        => 8,
            no_of_sample => 16
        )
        port map(
            clk           => tb_clk,
            sw            => tb_sw,
            uart_din      => tb_uart_din,

            uart_dout     => tb_uart_dout,
            sync          => tb_sync,
            dac_data      => tb_dac_data,
            s_clk         => tb_s_clk,
            led           => tb_led
        );

    DAC_RTL_MODEL: entity work.DAC_RTL_simulation_model
        port map(
            s_clk         => tb_s_clk,
            sync          => tb_sync,
            dac_data      => tb_dac_data,
            --output
            v_out          => tb_v_out
        );
    

    Clk: process
      begin
      tb_clk <= '0';
      wait for CLK_PERIOD / 2;
      tb_clk <= '1';
      wait for CLK_PERIOD / 2;
    end process;
    


stim: process 

    procedure send_uart_byte (
        constant data_in      : in std_logic_vector(7 downto 0);
        signal   tx_line      : out std_logic;
        constant exp_freq     : in real := 3900.0; -- used when frequency changed
        constant baud_period  : time := baud_period_460800 -- change this for desired baud rate
    ) is
        
    begin
        report ">>> Sending Command: " & character'val(to_integer(unsigned(data_in))) 
        severity note;

        check_enable <= false;
        -- Start Bit
        tx_line <= '0';
        wait for baud_period;
        
        -- Data Bits
        for i in 0 to 7 loop
            tx_line <= data_in(i);
            wait for baud_period;
        end loop;
        
        -- Stop Bit 
        tx_line <= '1';    
        expected_freq <= exp_freq;
        wait for 1 ms;
        check_enable <= true;
        wait for 5 ms;
    end procedure;


begin

    report "--- Starts with 390Hz Sawtooth Wave on Boot---";
    
    wait for 5 ms;

    -- Error cases
    send_uart_byte(CMD_A, tb_uart_din, 390.0);--A Valid Sawtooth waiting for frequency input(expected_freq input is for previous signal)
    send_uart_byte(CMD_9, tb_uart_din, 3900.0);--9 3900hz Sawtooth is generated
    send_uart_byte(CMD_A, tb_uart_din);--A Valid Sawtooth waiting for frequency input
    send_uart_byte(x"48", tb_uart_din);--H invalid
    send_uart_byte(CMD_2, tb_uart_din, 488.0);--2 488hz Sawtooth Signal is Generated
    send_uart_byte(CMD_B, tb_uart_din, 488.0); --B valid Square waiting for frequency input
    send_uart_byte(CMD_C, tb_uart_din, 488.0); --C invalid Triangle
    send_uart_byte(CMD_lower_a, tb_uart_din, 488.0); --a
    send_uart_byte(CMD_9, tb_uart_din, 3900.0); --9 3900hz Square Signal is Generated
    send_uart_byte(CMD_0, tb_uart_din); --0 invalid frequency can't change without a Wave type input
    send_uart_byte(x"47", tb_uart_din); --G invalid
    send_uart_byte(CMD_8, tb_uart_din); --8 1953hz invalid due to G is not a valid Wave type

    wait for 5 ms;

    

    -- Testing possible frequencies with every wave type
    for w in wave_type_hex'range loop
       
        for i in frequency'range loop
            send_uart_byte(wave_type_hex(w), tb_uart_din ,expected_freq_loop_2(i));
            send_uart_byte(frequency(i), tb_uart_din, expected_freq_loop_1(i));
            
        end loop;

    end loop;

    -- Testing Message print
    send_uart_byte(x"61", tb_uart_din); --a
    wait for 2 ms;

    send_uart_byte(x"62", tb_uart_din); --b
    wait for 2 ms;    

  wait;
  
end process;


check_process_freq: process
--Process that reports when the expected frequency is not equal to real value of it.
--Also reports when there is a change in the frequency.
    variable t_start           : time;
    variable t_end             : time;
    variable full_period       : time;
    variable freq_hz           : real;
    variable last_printed_freq : real := 390.0;
    variable freq_tolerance    : real := 0.0;
begin

    if check_enable = false then
        t_start := 0 ns;
        t_end := 0 ns;
        wait until check_enable =true;
    end if;
   
        wait until rising_edge(tb_led(7)) or (check_enable = false);
        if check_enable = true then
        t_start := now;

        
        wait until rising_edge(tb_led(7)) or (check_enable = false);
        if check_enable = true then
        t_end   := now;


        full_period := t_end - t_start;

        if full_period > 0 ns then
            freq_hz := 1.0e9 / real(full_period / 1 ns);
            
            if (expected_freq > 0.0) and (check_enable = true) then

                freq_tolerance := expected_freq * tolerance_percentage;

                assert(abs(freq_hz - expected_freq) <= freq_tolerance)
                    report LF & 
                        "----------------------------------------------------------------------" & LF &
                        " FREQUENCY ERROR!" & LF &
                        " Expected Value : " & real'image(expected_freq) & LF & 
                        " Real Value     : " & real'image(freq_hz) & LF & 
                        " Time           : " & time'image(now) & LF &
                        "----------------------------------------------------------------------"
                    severity error;

                if expected_freq /= last_printed_freq then
                    report LF & 
                        "----------------------------------------------------------------------" & LF &
                        " --- FREQUENCY CHANGED --- " & LF &
                        " New Frequency  : " & real'image(freq_hz) & " Hz" & LF &
                        " Time           : " & time'image(now) & LF &
                        "----------------------------------------------------------------------"
                    severity note;
                    last_printed_freq := expected_freq;
                end if;

            end if;
        end if;
    end if;  
end if; 
    

end process check_process_freq;

check_wave_type_pr: process 
--Wave type is identified by looking into 3 consecutive values of tb_led(represents the output)
--after "10000000" value. Since these values different for all of them we can easily identify.
    variable output_reg      : std_logic_vector(23 downto 0) := (others => '0');
    variable last_output_reg : std_logic_vector(23 downto 0) := x"818283"; -- Since design starts with Sawtooth

begin

    wait until rising_edge(tb_led(7));

    for i in 1 to 3 loop

        wait on tb_led;
        output_reg := output_reg(15 downto 0) & tb_led;

    end loop;

        if last_output_reg /= output_reg then

        case output_reg is

            when x"818283" =>
                report LF & 
                    "----------------------------------------------------------------------" & LF &
                    " --- NEW WAVE TYPE DETECTED ---" & LF &
                    " Wave Type      : Sawtooth" & LF &
                    " Time           : " & time'image(now) & LF &
                    "----------------------------------------------------------------------"
                severity note;
                last_output_reg := output_reg;

            when x"00FF00" =>
                report LF & 
                    "----------------------------------------------------------------------" & LF &
                    " --- NEW WAVE TYPE DETECTED ---" & LF &
                    " Wave Type      : Square" & LF &
                    " Time           : " & time'image(now) & LF &
                    "----------------------------------------------------------------------"
                severity note;
                last_output_reg := output_reg;

            when x"828486" =>
                report LF & 
                    "----------------------------------------------------------------------" & LF &
                    " --- NEW WAVE TYPE DETECTED ---" & LF &
                    " Wave Type      : Triangle" & LF &
                    " Time           : " & time'image(now) & LF &
                    "----------------------------------------------------------------------"
                severity note;
                last_output_reg := output_reg;

            when x"838689" =>
                report LF & 
                    "----------------------------------------------------------------------" & LF &
                    " --- NEW WAVE TYPE DETECTED ---" & LF &
                    " Wave Type      : Sine" & LF &
                    " Time           : " & time'image(now) & LF &
                    "----------------------------------------------------------------------"
                severity note;
                last_output_reg := output_reg;

            when others =>
                output_reg := (others => '0');

        end case;
    end if;
end process check_wave_type_pr;


check_voltage_pr: process (tb_v_out)
--Checks if the voltage boundaries are not exceeded. If its exceeded the tb breaks.
begin
assert (tb_v_out >= 0.0 and tb_v_out <= 3.3)
      report "v_out violated its boundaries vout = " & real'image(tb_v_out)
      severity failure; 

end process check_voltage_pr;

end architecture;


