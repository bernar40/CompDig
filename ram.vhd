-- Módulo responsável pela leitura e escrita na RAM
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity memoria_ram is
	PORT(
		clk : IN STD_LOGIC; 
		reset, r_w : IN STD_LOGIC;
		endereco : IN integer range 0 to 32;
		leitura : OUT STD_LOGIC_VECTOR(9 downto 0);
		escrita : IN STD_LOGIC_VECTOR(9 downto 0); 
		dado_30 : OUT STD_LOGIC_VECTOR (4 downto 0)
	);
end memoria_ram;


architecture arch_ram of memoria_ram is

	constant tam_mem: integer := 33;
	type ram_type is array(0 to tam_mem) of STD_LOGIC_VECTOR(9 downto 0);

	signal ram : ram_type := (
		0 => "ZZZZZZZZZZ", 
		1 => "ZZZZZZZZZZ", 
		2 => "ZZZZZZZZZZ",
		others => "ZZZZZZZZZZ"
	);
	signal leitura_r : std_logic_vector (9 downto 0) := (others => '0');

begin

dado_30 <= ram(30)(4 downto 0);

	process(clk, reset, r_w)
		begin
			if (rising_edge(clk)) then
				if reset = '1' then
					ram <= (0 => "0000100011",
							1 => "0000100011",
							2 => "0001001111",
							3 => "0010001111",
							4 => "0001101111",
							5 => "0010101111",
							6 => "0000100011",
							7 => "0011001111",
							8 => "0011101111",
							9 => "0100001111",
							10 => "0100101111",
							11 => "0101001111",
							12 => "0101101111",							
							13 => "0000100001",
							14 => "0011001111",
							15 => "0110111110",
							30 => "0001000000",
							31 => "0110011110",
							others => (others => '0'));
				elsif (r_w = '1') then
					leitura_r <= ram(endereco);
				else 
					ram(endereco) <= escrita;
				end if;
			end if;
		end process;
	leitura <= leitura_r;
end arch_ram;