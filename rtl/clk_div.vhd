--------------------------------------------------------------------------------
--! Project : eel4712c.lab4
--! Author  : Chase Ruskin
--! Course  : Digital Design - EEL4712C
--! Created : October 05, 2021
--! Entity  : clk_div
--! Details :
--!     Slows the original source clock set by generic input frequency to a 
--!     single-cycle pulse of the generic output frequency.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity clk_div is
    generic (
        --! incoming clock frequency (Hz)
        CLK_IN_FREQ  : natural;
        --! desired output clock frequency (Hz)
        CLK_OUT_FREQ : natural
    );
    port(
        --! source clock input
        clk_src  : in  std_logic;
        rst      : in  std_logic;
        --! target clock target
        clk_tgt : out std_logic
    );
end entity;


architecture rtl of clk_div is
    constant MAX_COUNT : natural := (clk_in_freq/clk_out_freq)-1;
    
    -- internal register to store delay values
    signal ctr : natural range 0 to MAX_COUNT;

begin
    -- divide the incoming clock
    process(clk_src, rst)
    begin
        if rst = '1' then
            ctr <= 0;
            clk_tgt <= '0';
        elsif rising_edge(clk_src) then
            -- reset the counter and generate a pulse
            if(ctr >= MAX_COUNT) then
                clk_tgt <= '1';
                ctr <= 0;
            -- drive output low while counting/delaying
            else
                clk_tgt <= '0';
                ctr <= ctr + 1;
            end if;

        end if;
    end process;

end architecture;