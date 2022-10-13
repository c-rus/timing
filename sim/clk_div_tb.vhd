--------------------------------------------------------------------------------
--! Project : eel4712c.lab4
--! Author  : Chase Ruskin
--! Course  : Digital Design - EEL4712C
--! Created : October 13, 2022
--! Entity  : clk_div_tb
--! Details :
--!     Verifies the `clk_div` entity produces an enable signal slowed by a
--!     generic `RATIO`.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity clk_div_tb is
    generic (
        RATIO : positive := 4
    );
end entity clk_div_tb;


architecture sim of clk_div_tb is
    -- wires for UUT port connections
    signal clk_src : std_logic := '0';
    signal clk_tgt : std_logic;
    signal rst     : std_logic;

    -- internal testbench signal to stop the simulation
    signal halt : std_logic := '0';

    constant CLK_PERIOD : time := 20 ns;

begin 
    --! instantiate the unit-under-test (UUT)
    uut : entity work.clk_div
    generic map (
        CLK_IN_FREQ  => RATIO,
        CLK_OUT_FREQ => 1
    ) port map (
        clk_src => clk_src,
        rst     => rst,
        clk_tgt => clk_tgt
    );

    --! generate clock with 50% duty cycle
    clk_src <= not clk_src after CLK_PERIOD/2 when halt = '0';

    --! perform initial reset process
    boot : process
    begin
        rst <= '1';
        -- wait for 5 cycles
        for i in 0 to 5 loop
            wait until rising_edge(clk_src);
        end loop;
        -- force reset to be lowered on non-rising edge of `clk_src`
        wait for 5 ns;
        rst <= '0';
        wait;
    end process;

    --! verify the target clock is slowed according to `RATIO`
    bench : process
    begin
        wait until rst = '0' and rising_edge(clk_src);

        -- assert 3 output enables for `clk_tgt`
        for ii in 1 to RATIO*3+1 loop 
            wait until rising_edge(clk_src); 
            if ii rem RATIO = 0 then
                assert clk_tgt = '1' report "target clock not triggered in ratio bound" severity failure;
            else 
                assert clk_tgt = '0' report "target clock set outside single cycle" severity failure;
            end if;

        end loop;

        halt <= '1';
        report "Simulation complete";
        wait;
    end process;

end architecture sim;