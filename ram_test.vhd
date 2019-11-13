LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY RAM_TEST IS
END RAM_TEST;
 
ARCHITECTURE behavior OF RAM_TEST IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT memoria_ram
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         r_w : IN  std_logic;
			endereco : IN integer range 0 to 31;
         leitura : OUT  std_logic_vector(4 downto 0);
			escrita : IN  std_logic_vector(4 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal r_w : std_logic := '0';
	signal endereco : integer range 0 to 31 := 0;
	signal escrita : std_logic_vector(4 downto 0);

 	--Outputs
   signal leitura : std_logic_vector(4 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: memoria_ram PORT MAP (
          clk => clk,
          reset => reset,
          r_w => r_w,
			 endereco => endereco,
          leitura => leitura,
			 escrita => escrita
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
	
	reset <= '1';
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		reset <= '0';
		r_w <= '1';
		endereco <= 0;
      wait for clk_period*10;
		reset <= '0';
		r_w <= '1';
		endereco <= 0;
		
--		wait for clk_period*10;
--		reset <= '0';
--		r_w <= '0';
		
		
		wait for clk_period*10;
		reset <= '0';
		r_w <= '1';
		endereco<= 2;

--		wait for clk_period*10;
--		r_w <= '0';
		
		wait for clk_period*10;
		r_w <= '1';
		endereco <= 3;
		
		wait for clk_period*10;
		r_w <= '1';
		
      -- insert stimulus here 

      wait;
   end process;

END;
