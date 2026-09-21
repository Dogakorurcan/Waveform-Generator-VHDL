library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.wave_gen_pkg.all;

entity wave_gen_top is
    generic(
        osc_freq     : integer := 100000000;
        width        : integer := 8;
        no_of_sample : integer := 16
    );
    port (
        --inputs
        clk       : in std_logic;
        uart_din  : in std_logic;
        sw        : in std_logic_vector(2 downto 0);

        --outputs
        uart_dout : out std_logic;
        sync      : out std_logic;
        dac_data  : out std_logic;
        s_clk     : out std_logic;
        led       : out std_logic_vector(7 downto 0)
   
    );
end entity wave_gen_top;

architecture behav of wave_gen_top is
    --uart top

    signal tx_data           : std_logic_vector(7 downto 0);
    signal tx_send           : std_logic;
    signal tx_dout           : std_logic;
    signal tx_active         : std_logic;
    signal rx_data_ready     : std_logic;
    signal rx_data           : std_logic_vector(7 downto 0);

    --cmd_handler
    signal cmd_ready         : std_logic; 
    signal cmd               : std_logic_vector(15 downto 0);

    --en_gen
    signal freq              : std_logic_vector(7 downto 0);
    signal en_out            : std_logic;

    --wave_gen
    signal wave_out          : std_logic_vector(7 downto 0);

    --sclk_gen
    signal edge_low          : std_logic;

begin

    inst_uart_top: entity work.uart_top
        generic map(
            osc_freq     => osc_freq,
            width        => width,
            no_of_sample => no_of_sample
        )
        port map(
            clk           => clk,
            sw            => sw,
            rx_din        => uart_din,
            tx_data       => tx_data,
            tx_send       => tx_send,

            tx_dout       => uart_dout,
            tx_active     => tx_active,
            rx_data_ready => rx_data_ready,
            rx_data       => rx_data
        );


        inst_cmd_handler: entity work.cmd_handler
        port map(
            clk           => clk,
            sw            => sw,
            tx_active     => tx_active,
            rx_data_ready => rx_data_ready,
            rx_data       => rx_data,


            tx_data       => tx_data,
            tx_send       => tx_send,
            cmd_ready     => cmd_ready,
            cmd           => cmd

        );

    inst_en_gen: entity work.en_gen
        port map(
            clk           => clk,
            cmd_rdy       => cmd_ready,
            freq          => cmd(7 downto 0),

            en_out        => en_out
        );

    inst_wave_gen: entity work.wave_gen
        port map(
            clk           => clk,
            cmd_rdy       => cmd_ready,
            en            => en_out,
            wave_type     => cmd(15 downto 8),
            
            wave_out       => wave_out
        );

    inst_sclk_gen: entity work.sclk_gen
        port map(
            clk           => clk,

            edge_low      => edge_low,
            sclk          => s_clk
        );

    inst_sync_data_gen: entity work.sync_data_gen
        port map(
            clk           => clk,
            en            => en_out,
            edge_low      => edge_low,
            wave          => wave_out,

            dac_data      => dac_data,
            sync          => sync
        );

            led <= wave_out;

end architecture behav;

