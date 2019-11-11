----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:40:17 11/11/2019 
-- Design Name: 
-- Module Name:    alu - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
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
end alu;


architecture arch_alu of alu is

TYPE state_type IS (idle, processing, finish, set);
SIGNAL pst : state_type := idle;
SIGNAL temp_result : std_logic_vector (4 downto 0);

begin
	process(clk, start, pst, opcode, operando1, operando2) 
		begin
			if (rising_edge(clk)) then 
				case pst is
					when idle => 
						if(start = '1') then
							pst <= processing;
							n_z_flag <= "00";
						end if;
					when processing =>
						case opcode is
							when "00101" => temp_result <= (unsigned(operando1) + unsigned(operando2));		--A + B 
									
							when "00110" => temp_result <= (unsigned(operando1) - unsigned(operando2));		-- A - B
							
							when "00111" => temp_result <= operando1 AND operando2;									-- A AND B

							when "01000" => temp_result <= operando1 OR operando2;									-- A OR B

							when "01001" => temp_result <= operando1 XOR operando2;									-- A XOR B

							when "01010" => temp_result <= NOT operando1;												-- NOT A

							when "01011" => temp_result <= operando1 NAND operando2;									-- A NAND B

							when "10000" => temp_result <= std_logic_vector(operando1 + 1);						-- INC A

							when "10001" => temp_result <= std_logic_vector(operando2 + 1);						-- INC B

							when "10010" => temp_result <= std_logic_vector(operando1 - 1);						-- DEC A

							when "10011" => temp_result <= std_logic_vector(operando2 - 1);						-- DEC B

							when others => temp_result <= "00000";
						end case;
						pst <= finish;

					when finish =>
						result <= temp_result;
						done <= '1';
						pst <= set;
						if (unsigned(temp_result) = 0) then
							n_z_flag <= "01";
						elsif (operando2 > operando1 and opcode = "00110") then
							n_z_flag <= "10";
						else
							n_z_flag <= "00";
						end if;
						
					when set =>
						done <= '0';
						pst <= idle;
					
					when others =>
						pst <= idle;
				end case;
			end if;
		end process;
end arch_alu;

