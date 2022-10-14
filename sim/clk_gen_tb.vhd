--------------------------------------------------------------------------------
--! Entity: clk_gen_tb
--! Adapted from: Dr. Stitt, UF ECE Professor
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_gen_tb is
generic (
    MS_PERIOD : positive := 2
);
end entity clk_gen_tb;


architecture sim of clk_gen_tb is
    
    signal clk      : std_logic := '0';
    signal rst      : std_logic;
    signal button_n : std_logic;
    signal clk_out  : std_logic;
    signal en       : std_logic;

    signal halt     : std_logic := '0';

    -- allow for time if enabling between clocks
    constant MAX_TIME  : time    := (MS_PERIOD+1)*1 ms;
    -- the generated clock should never occure before `MIN_TIME` after enabled
    constant MIN_TIME  : time    := (MS_PERIOD)*1 ms;
    -- 50 MHz clock period
    constant CLK_PERIOD : time := 20 ns;

begin
    en <= not button_n;

    uut : entity work.clk_gen
    generic map (
        CLK_IN_FREQ  => 50_000_000,
        -- divide to get 1kHz clock
        CLK_OUT_FREQ => 1_000, 
        PERIOD       => MS_PERIOD
    ) port map (
        clk_src => clk,
        rst     => rst,
        en      => en,
        clk_tgt => clk_out
    );

    clk <= not clk after CLK_PERIOD/2 when halt = '0';

    bench : process
        variable before_time, after_time : time;
    begin
        rst <= '1';
        button_n <= '1';
        wait for 100 ns;

        rst <= '0';
        button_n <= '0';

        before_time := now;
        wait until clk_out = '1' for MAX_TIME;
        after_time  := now;

        if (clk_out = '0') then
            report "Clock not generated.";
        end if;

        if ((after_time-before_time) < MIN_TIME) then
            report "Clock generated too soon." & time'image(after_time-before_time);
            report "Min time = " & time'image(MIN_TIME);
        end if;

        before_time := now;
        wait until clk_out = '1' for MAX_TIME;
        after_time  := now;

        if (clk_out = '0') then
            report "Clock not generated for continued press.";
        end if;

        if (after_time-before_time < MIN_TIME) then
            report "Clock generated too soon for generated press." & time'image(after_time-before_time);
            report "Min time = " & time'image(MIN_TIME);
        end if;

        wait for 1 ms;

        button_n <= '1';
        wait until clk_out = '1' for 2*MAX_TIME;

        if (clk_out = '1') then
            report "Clock generated when button not pressed.";
        end if;

        button_n    <= '0';
        before_time := now;
        wait until clk_out = '1' for MAX_TIME;
        after_time  := now;

        if (clk_out = '0') then
            report "Clock not generated for pressed button after release.";
        end if;

        if (after_time-before_time < MIN_TIME) then
            report "Clock for pressed button after release generated too soon." & time'image(after_time-before_time);
            report "Min time = " & time'image(MIN_TIME);
        end if;

        halt <= '1';
        report "Simulation complete.";
        wait;

    end process;

end architecture sim;