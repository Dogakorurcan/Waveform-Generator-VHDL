library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_top is
    generic(
        osc_freq     : integer;
        width        : integer;
        no_of_sample : integer
    );
    port(
        --inputs
        clk     : in std_logic;
        sw      : in std_logic_vector(2 downto 0);
        rx_din  : in std_logic;
        tx_data : in std_logic_vector(7 downto 0);
        tx_send : in std_logic;

        --outputs
        tx_dout       : out std_logic;
        tx_active     : out std_logic;
        rx_data_ready : out std_logic;
        rx_data       : out std_logic_vector(7 downto 0)
    );
end entity uart_top;

architecture struct of uart_top is 

    signal tx_active_i: std_logic;
    signal rx_active  : std_logic;
    signal baud_en_rx : std_logic;
    signal baud_en_tx : std_logic;
    signal data_in    : std_logic;
    signal tx_data_out: std_logic;


begin

    inst_baudrate_gen: entity work.baudrate_gen
        generic map(
            osc_freq     => 100000000,
            no_of_sample => 16
        )
        port map(
            clk        => clk,
            sw         => sw,
            rx_active  => rx_active,
            tx_active  => tx_active_i,
            baud_en_rx => baud_en_rx,
            baud_en_tx => baud_en_tx
        );
    
    inst_u_tx: entity work.u_tx
        generic map(
            width        => 8,
            no_of_sample => 16
        )
        port map(
            clk         => clk,
            tx_send     => tx_send,
            data_in     => tx_data,
            baud_en_tx  => baud_en_tx,
            tx_data_out => tx_dout,
            tx_active   => tx_active_i
        );

    inst_u_rx: entity work.u_rx
        generic map(
            width        => 8,
            no_of_sample => 16
        )
        port map(
            clk            => clk,
            data_in        => rx_din,
            baud_en_rx     => baud_en_rx,
            data_out       => rx_data,
            rx_active      => rx_active,
            rx_data_ready  => rx_data_ready
            );
        
        tx_active <= tx_active_i;
            




end architecture struct;



