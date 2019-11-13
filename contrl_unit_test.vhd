LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY UC_TEST IS
END UC_TEST;
 
ARCHITECTURE behavior OF UC_TEST IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT control_unit
		PORT(
				clk 						: IN std_logic;
				reset 					: IN std_logic;
				zero_flag_led	 		: OUT std_logic := '0';
				negative_flag_led 	: OUT std_logic := '0';
				debug_command 			: OUT std_logic_vector (4 downto 0)
		);
	END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal zero_flag_led : std_logic;
   signal negative_flag_led : std_logic;
	signal debug_command : std_logic_vector (4 downto 0);

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: control_unit PORT MAP (
			clk => clk,
			reset => reset,
			zero_flag_led => zero_flag_led,
			negative_flag_led => negative_flag_led,
			debug_command => debug_command

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
      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
