-- Módulo principal responsável pelo controle da CPU
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control_unit is
	PORT(
		clk 						: IN std_logic;
		reset 					: IN std_logic;
		zero_flag_led	 		: OUT std_logic := '0';
		negative_flag_led 	: OUT std_logic := '0';
		debug_command 			: OUT std_logic_vector (4 downto 0)
	);
end control_unit;

architecture arch_control_unit of control_unit is
	
component memoria_ram
    port (
			clk 			: IN std_logic;
			reset, r_w	: IN std_logic;
			endereco 		: IN integer range 0 to 32;
			leitura 		: OUT std_logic_vector (9 downto 0);
			escrita 		: IN std_logic_vector (9 downto 0);
			dado_30 		: OUT std_logic_vector (4 downto 0)
			);
end component;

component alu

    port (
		clk  			: IN  std_logic;
		operando1 	: IN std_logic_vector(4 downto 0);
		operando2 	: IN std_logic_vector(4 downto 0);
		opcode 		: IN std_logic_vector(4 downto 0);
		start			: IN std_logic;
		result 		: OUT std_logic_vector(4 downto 0);
		done 			: OUT std_logic;
		n_z_flag 	: OUT std_logic_vector(1 downto 0)
	);
end component;

--SINAIS RAM
SIGNAL r_w 			: std_logic;
SIGNAL endereco 	: integer range 0 to 32;
SIGNAL escrita 	: std_logic_vector ( 9 downto 0);
SIGNAL leitura 	: std_logic_vector ( 9 downto 0);

--SINAIS ALU
SIGNAL inst				: std_logic_vector ( 4 downto 0);
SIGNAL result 			: std_logic_vector ( 4 downto 0);
SIGNAL start_ALU	 	: std_logic;
SIGNAL done_ALU 		: std_logic;
SIGNAL n_z_flag 		: std_logic_vector ( 1 downto 0) := "00";

--SINAIS CONTROL UNIT
SIGNAL position 			: integer range 0 to 32 := 0;
SIGNAL rA 	 				: std_logic_vector ( 4 downto 0);
SIGNAL rB					: std_logic_vector ( 4 downto 0);
SIGNAL command				: std_logic_vector ( 4 downto 0):= "00000";
SIGNAL value 	 			: std_logic_vector ( 4 downto 0):= "00000";
SIGNAL n_z_flag_cunit 		: std_logic_vector ( 1 downto 0) := "00";
SIGNAL cont_loop 			: unsigned(25 downto 0) := "00000000000000000000000000";

-- CONTROLE DO CLOCK
signal clk_2seg : STD_LOGIC;
signal count_clk : INTEGER := 0;
signal direction_clk : STD_LOGIC := '1';

-- ESTADOS DE EXECUCAO
TYPE state_type IS (idle, reading, fecthing, processing, processing_ALU, wait_st, finishing);
SIGNAL pst_uc	: 	state_type := idle;

begin
RAM_UC: RAM port map (clk=>clk, reset=>reset, r_w=>r_w, endereco=>endereco, leitura=>leitura, escrita=>escrita, dado_30=>mem30);
ALU_UC: ALU port map (clk=>clk, inst=>command, operador1=>rA, operador1=>rB, result=>result, start=>start_ALU, done=>done_ALU, n_z_flag => n_z_flag);


negative_flag_led <= n_z_flag_cunit(0);
zero_flag_led <= n_z_flag_cunit(1);

debug_command <= command;

-- Processo que transforma o clock de 50MHZ em 0,5HZ
	process (clk)
	begin
		if (clk'event and clk = '1') then
			if (count_clk < 50000000 and direction_clk = '1') then
					clk_2seg <= '0';
					count_clk <= count_clk + 1;
			elsif (count_clk < 100000000 and direction_clk = '1') then
					clk_2seg <= '1';
					count_clk <= count_clk + 1;
			else 
					count_clk <= 0;
			end if;
			debug_clk500hz <= clk_2seg;
		end if;
	end process;


-- Processo que troca estado a cada subida do clock de 2 segundos
	process (clk_2seg)
	begin
		if (clk_2seg'event and clk_2seg = '1') then
			if (reset = '1') then
				position <= 1;
				rA <= "00000";
				rB <= "00000";
				pst_uc <= idle;
				start_ALU <= '0';
				nz_flag <= "00";
				ps <= ns;
			else
				case pst_uc is
					when idle =>
						start_ALU <= '0';
						r_w <= '1'; -- set leitura 
						endereco <= position;
						pst_uc <= reading;
					when reading =>
						r_w <= '1'; -- set leitura
						pst_uc <= fecthing;
					when fecthing => 
						command <= leitura(9 downto 5);
						value <= leitura(4 downto 0);
						pst_uc <= processing;
					when processing =>
							case command is 
								when "00001" => -- MOV A, end
									r_w <= '1';
									rA <= leitura( 4 downto 0);
									pst_uc <= wait_st;
								when "00010" => -- MOV end, A
									escrita (4 downto 0) <= rA;
									escrita (9 downto 5) <= "00001";
									r_w <= '0';
									pst_uc <= wait_st;
								when "00011" => -- MOV A, B
									rA <= rB;
									pst_uc <= wait_st;	
								when "00100" => -- MOV B, A
									rB <= rA;
									pst_uc <= wait_st;
								when "00101" => -- ADD A, B
									start_ALU <= '1';
									pst_uc <= processing_ALU;
								when "00110" => -- SUB A, B
									start_ALU <= '1';
									pst_uc <= processing_ALU;	
								when "00111" => -- A AND B
									start_ALU <= '1';
									pst_uc <= processing_ALU;
								when "01000" => -- A OR B
									start_ALU <= '1';
									pst_uc <= processing_ALU;	

								when "01001" => -- A XOR B
									start_ALU <= '1';
									pst_uc <= processing_ALU;	

								when "01010" => -- NOT A
									start_ALU <= '1';
									pst_uc <= processing_ALU;	
									
								when "01011" => -- A NAND B
									start_ALU <= '1';
									pst_uc <= processing_ALU;	
--								when JZ, when JN, others...
							end case;
						when processing_ALU =>
							n_z_flag_cunit <= n_z_flag;
							if (done_ALU = '1') then
										pst_uc <= wait_st;
										rA <= result;
							end if;
--						when wait_st, finising, others.. 
				end case;
			end if;
		end if;
	end process;

end arch_control_unit;