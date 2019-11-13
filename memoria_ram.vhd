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
							1 => 		"10000",
							2 => 		"10000",
							3 => 		"10000",
							4 => 		"10000",
							5 => 		"10000",
							6 => 		"10000",
							7 => 		"10000",
							8 => 		"10000",
							9 => 		"10000",
							10 => 	"10000",
							11 => 	"10000",
							12 => 	"10000",							
							13 => 	"10000",
							14 => 	"10000",
							15 => 	"10000",
							16 => 	"10000",
							17 => 	"10000",
							18 => 	"10000",							
							19 => 	"10000",
							20 => 	"10000",
							21 => 	"10000",
							22 => 	"10000",
							23 => 	"10000",
							24 => 	"10000",
							25 => 	"10000",
							26 => 	"10000",
							27 => 	"10000",
							28 => 	"10000",
							29 => 	"10000",
							30 => 	"10000",
							31 => 	"10000");
				elsif (r_w = '1') then
					leitura_r <= ram(endereco);
				else 
					ram(endereco) <= escrita;
				end if;
			end if;
		end process;
	leitura <= leitura_r;
end arch_ram;