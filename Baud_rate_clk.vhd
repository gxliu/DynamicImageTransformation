--Example Use:
-- baudrate_generator: entity clock_generator
--    generic map(clock_in_speed => 50e6, clock_out_speed => 9600)  --input clock is 50MHz, output is 9600
--    port map(
--      clock_in => clock,                                           --from the top level
--      clock_out => baudrate_clock);                                --int. clk for communicating at 9600

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_generator is
  generic(clock_in_speed, clock_out_speed, num_bits: integer);
  port(
    clock_in: in std_logic;
    clock_out: out std_logic);
end entity clock_generator;

architecture rtl of clock_generator is

  constant max_counter: natural := clock_in_speed / clock_out_speed / 2;
  constant counter_bits: natural := num_bits;

  signal counter: unsigned(counter_bits - 1 downto 0) := (others => '0');
  signal clock_signal: std_logic;

begin
  update_counter: process(clock_in)
  begin
    if clock_in'event and clock_in = '1' then
      if counter = max_counter then
        counter <= to_unsigned(0, counter_bits);
        clock_signal <= not clock_signal;
      else
        counter <= counter + 1;
      end if;
    end if;
  end process;

  clock_out <= clock_signal;
end architecture rtl;