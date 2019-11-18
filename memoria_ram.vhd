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
							2 => 		"00111",
							3 => 		"01000",
							4 => 		"01001",
							5 => 		"01010",
							6 => 		"00101",
							7 => 		"00110",
							8 => 		"01011",
							9 => 		"10000",
							10 => 	"10001",
							11 => 	"10010",
							12 => 	"10011",							
							13 => 	"01110",
							14 => 	"00010",
							15 => 	"11101",
							16 => 	"11111",
							17 => 	"00001",
							18 => 	"11110",							
							19 => 	"01110",
							20 => 	"01110",
							21 => 	"01101",
							22 => 	"11110",
							23 => 	"10010",
							24 => 	"10010",
							25 => 	"10010",
							26 => 	"10010",
							27 => 	"10010",
							28 => 	"10010",
							29 => 	"11111",
							30 => 	"10010",
							31 => 	"11111");
				elsif (r_w = '1') then
					leitura_r <= ram(endereco);
				else 
					ram(endereco) <= escrita;
				end if;
			end if;
		end process;
	leitura <= leitura_r;
end arch_ram;