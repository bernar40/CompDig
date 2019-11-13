-- Módulo responsável pela leitura e escrita na RAM
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity memoria_ram is
	PORT(
		clk : IN STD_LOGIC; 
		reset, r_w : IN STD_LOGIC;
		endereco : IN integer range 0 to 31;
		leitura : OUT STD_LOGIC_VECTOR(4 downto 0);
		escrita : IN STD_LOGIC_VECTOR(4 downto 0); 
		dado_30 : OUT STD_LOGIC_VECTOR (4 downto 0)
	);
end memoria_ram;


architecture arch_ram of memoria_ram is

	constant tam_mem: integer := 31;
	type ram_type is array(0 to tam_mem) of STD_LOGIC_VECTOR(4 downto 0);

	signal ram : ram_type := (
		0 => "ZZZZZ", 
		1 => "ZZZZZ", 
		2 => "ZZZZZ",
		others => "ZZZZZ"
	);
	signal leitura_r : std_logic_vector (4 downto 0) := (others => '0');

begin

dado_30 <= ram(30)(4 downto 0);

	process(clk, reset, r_w)
		begin
			if (rising_edge(clk)) then
				if reset = '1' then
					ram <= (0 => 	"10000",
							1 => 		"10001",
							2 => 		"10000",
							3 => 		"10000",
							4 => 		"00101",
							5 => 		"00110",
							6 => 		"01001",
							7 => 		"01010",
							8 => 		"01011",
							9 => 		"01101",
							10 => 	"11110",
							11 => 	"01111",
							12 => 	"11111",							
							13 => 	"10000",
							14 => 	"10000",
							15 => 	"10000",
							16 => 	"00111",
							17 => 	"01000",
							18 => 	"01001",							
							19 => 	"01010",
							20 => 	"01011",
							21 => 	"01101",
							22 => 	"11110",
							23 => 	"10010",
							24 => 	"10010",
							25 => 	"10010",
							26 => 	"10010",
							27 => 	"10010",
							28 => 	"10010",
							29 => 	"10010",
							30 => 	"10010",
							31 => 	"00000");
				elsif (r_w = '1') then
					leitura_r <= ram(endereco);
				else 
					ram(endereco) <= escrita;
				end if;
			end if;
		end process;
	leitura <= leitura_r;
end arch_ram;