# `chrono.timing`

## Overview

Modules for varying and manipulating clock and pulses for synchronization techniques.

## Entities

- `clk_div`

Slows the original source clock set by generic input frequency to a single-cycle pulse of the generic output frequency.

- `clk_gen`

Generates a pulse (rising edge) when `en` is asserted for `PERIOD` pulses divided by `CLK_IN_FREQ`/`CLK_OUT_FREQ`.

## Organization
- `rtl`: synthesizable design code
- `sim`: simulation code (testbenches)
- `docs`: specification and documentation files