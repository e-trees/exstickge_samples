library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sccb_bmem_tb is
end entity sccb_bmem_tb;


architecture RTL of sccb_bmem_tb is
  
  COMPONENT sccb_bmem IS
    PORT (
      --Port A
      ADDRA      : IN  STD_LOGIC_VECTOR(8 DOWNTO 0);
      DOUTA      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      CLKA       : IN  STD_LOGIC
      );
  END COMPONENT;

  signal clk : std_logic := '0';
  signal addr : unsigned(8 downto 0) := (others => '0');
  signal dout : std_logic_vector(31 downto 0) := (others => '0');

  signal counter : unsigned(31 downto 0) := (others => '0');
  
begin

  process
  begin
    clk <= not clk;
    wait for 5ns;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      case to_integer(counter) is
        when 10 =>
          addr <= addr + 1;
        when others =>
          counter <= counter + 1;
      end case;
    end if;
  end process;

  U: sccb_bmem
    PORT map(
      ADDRA  => std_logic_vector(addr),
      DOUTA  => dout,
      CLKA   => clk
      );
  
end RTL;
