--------------------------------------------------------------------------------
-- Project: eel4712c.lab4
-- Author: Chase Ruskin
-- Course: Digital Design - EEL4712C
-- Creation Date: October 05, 2021
-- Entity: clk_gen
-- Description:
--  Generates a pulse (rising edge) every 1 second when a button has been pressed for
--  1 second.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity clk_gen is
    generic(
        --! amount of ms for button to be pressed before creating clock pulse
        ms_period : positive
    );          
    port(
        --! source clock
        clk_src  : in  std_logic;
        rst      : in  std_logic;
        --! enable signal
        en       : in  std_logic;
        --! target clock
        clk_trg  : out std_logic
    );
end entity;

architecture rtl of clk_gen is

    constant CLK_IN_FREQ  : natural := 50_000_000; -- FPGA clock frequency 50MHz
    constant CLK_OUT_FREQ : natural := 1_000;     -- desired clock frequency 1kHz

    --internal register to count how many ms_periods must occur before output clk_out = '1'
    signal counter : natural range 0 to ms_period-1;
    
    --wire connecting clk_div output used as an enable
    signal pulse1kHz : std_logic;

    --internal register to store the clk_out state
    signal clk_out_i : std_logic;

    component clk_div is
        generic(
            clk_in_freq  : natural;
            clk_out_freq : natural
        );
        port(
            clk_in  : in  std_logic;
            clk_out : out std_logic;
            rst     : in  std_logic
        );
    end component;

begin
    --instantiate a clock divider to output pulses every 1ms
    u0_slow_clock : clk_div
    generic map(
        clk_in_freq=>clk_in_freq,
        clk_out_freq=>clk_out_freq
    )
    port map(
        clk_in=>clk50MHz,
        clk_out=>pulse1kHz,
        rst=>button_n   --turn on clock divider when the button is pressed
    );

    -- process to store how many counts have occured
    process(clk50Mhz, rst) begin
        if(rst = '1') then
            counter <= 0;
            clk_out_i <= '0';
        elsif(rising_edge(clk50MHz)) then
            -- enable the counter when the button is pressed
            if(button_n = '0') then
                -- hit top of counter/delayer
                if(pulse1kHz = '1' and counter >= ms_period-1) then
                    clk_out_i <= '1';
                    counter <= 0;
                -- increment counter on every 1ms pulse
                elsif(pulse1kHz = '1') then
                    counter <= counter + 1;
                    clk_out_i <= '0';
                end if;
            -- reset the counter if the button is released
            else
                -- toggle off clk_out if the wait time is equal to 1
                if(ms_period = 1) then
                    clk_out_i <= '0';
                end if;
                counter <= 0;
            end if;

        end if;
    end process;

    --simple pass-through
    clk_out <= clk_out_i;

end architecture;
