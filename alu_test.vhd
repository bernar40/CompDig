LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY ALU_TEST IS
END ALU_TEST;
 
ARCHITECTURE behavior OF ALU_TEST IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT alu
		port (
			clk  			: IN  std_logic;
			operando1 	: IN std_logic_vector(4 downto 0);
			operando2 	: IN std_logic_vector(4 downto 0);
			opcode 		: IN std_logic_vector(4 downto 0); -- opcode do comando atual a ser executado
			start			: IN std_logic;
			result 		: OUT std_logic_vector(4 downto 0); -- resultado da operacao
			done 			: OUT std_logic;
			n_z_flag 	: OUT std_logic_vector(1 downto 0)  -- flag de resultado -> 00 = normal, 01 = Zero, 10 = Negativo
		);
    END COMPONENT;
    

   --Inputs
   signal clk 			: std_logic := '0';
   signal opcode 		: std_logic_vector(4 downto 0) := (others => '0');
   signal operando1 	: std_logic_vector(4 downto 0) := (others => '0');
   signal operando2 	: std_logic_vector(4 downto 0) := (others => '0');
   signal start 		: std_logic := '0';

 	--Outputs
   signal result 	: std_logic_vector(4 downto 0);
   signal done 	: std_logic;
	signal n_z_flag 		: std_logic_vector(1 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: alu PORT MAP (
		clk => clk,
		operando1 => operando1,
		operando2 => operando2,
		opcode => opcode,
		result => result,
		start => start,
		done => done,
		n_z_flag => n_z_flag
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

		operando1 <= "00001";
		operando2 <= "10000";
		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		opcode <= "00101";
		start <= '1';
		wait for clk_period;
		start <= '0';

		
		
		
		wait for clk_period*10;
		operando1 <= "00000";
		operando2 <= "00001";
		opcode <= "00110";
		start <= '1';
		wait for clk_period;
		start <= '0';
		


		

      -- insert stimulus here 

      wait;
   end process;

END;
