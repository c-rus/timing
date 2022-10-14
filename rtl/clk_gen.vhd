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
    generic (
        --! incoming global clock frequency
        CLK_IN_FREQ  : natural;
        --! desired clock frequency
        CLK_OUT_FREQ : natural;
        --! amount of pulses required for `en` to be asserted before generating clock
        PERIOD : natural
    );          
    port (
        --! source clock
        clk_src  : in  std_logic;
        rst      : in  std_logic;
        --! enable signal
        en       : in  std_logic;
        --! target clock
        clk_tgt  : out std_logic
    );
end entity clk_gen;

architecture rtl of clk_gen is

    -- internal register to count how many PERIODs must occur before output clk_out = '1'
    signal counter : natural range 0 to PERIOD-1;
    
    -- wire connecting clk_div output used as an enable
    signal pulse : std_logic;

    signal clk_div_rst : std_logic;

    -- internal register to store the clk_out state
    signal clk_tgt_i : std_logic;

begin
    clk_div_rst <= not en;

    -- instantiate a clock divider to output pulses dependent on desired frequency
    u_slow_clock : entity work.clk_div
    generic map (
        CLK_IN_FREQ  => CLK_IN_FREQ,
        CLK_OUT_FREQ => CLK_OUT_FREQ
    ) port map (
        clk_src => clk_src,
        -- turn on the clock divider when enable is '1'
        rst     => clk_div_rst,
        clk_tgt => pulse
    );

    -- process to store how many counts have occured
    process(clk_src, rst) begin
        if rst = '1' then
            counter <= 0;
            clk_tgt_i <= '0';
        elsif rising_edge(clk_src) then
            -- enable the counter when the button is pressed
            if en = '1' then
                -- hit top of counter/delayer
                if pulse = '1' and counter >= PERIOD-1 then
                    clk_tgt_i <= '1';
                    counter <= 0;
                -- increment counter on every 1ms pulse
                elsif pulse = '1' then
                    counter <= counter + 1;
                    clk_tgt_i <= '0';
                end if;
            -- reset the counter if the enable is lowered
            else
                -- toggle off clk_out if the wait time is equal to 1
                if PERIOD = 1 then
                    clk_tgt_i <= '0';
                end if;
                counter <= 0;
            end if;

        end if;
    end process;

    -- simple pass-through
    clk_tgt <= clk_tgt_i;

end architecture;
