-- M?dulo principal respons?vel pelo controle da CPU
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
			endereco 	: IN integer range 0 to 31;
			leitura 		: OUT std_logic_vector (4 downto 0);
			escrita 		: IN std_logic_vector (4 downto 0);
			dado_30 		: OUT std_logic_vector (4 downto 0)
			);
end component;

component alu

    port (
		clk  				: IN  std_logic;
		operando1 		: IN std_logic_vector(4 downto 0);
		operando2 		: IN std_logic_vector(4 downto 0);
		opcode 			: IN std_logic_vector(4 downto 0);
		start				: IN std_logic;
		result 			: OUT std_logic_vector(4 downto 0);
		done 				: OUT std_logic;
		zero_flag 		: OUT std_logic := '0';
		negative_flag 	: OUT std_logic := '0'
	);
end component;

--SINAIS RAM
SIGNAL r_w 			: std_logic;
SIGNAL endereco 	: integer range 0 to 31;
SIGNAL escrita 	: std_logic_vector ( 4 downto 0);
SIGNAL leitura 	: std_logic_vector ( 4 downto 0);
SIGNAL mem30		: std_logic_vector ( 4 downto 0);

--SINAIS ALU
SIGNAL opcode			: std_logic_vector ( 4 downto 0);
SIGNAL result 			: std_logic_vector ( 4 downto 0);
SIGNAL start_ALU	 	: std_logic;
SIGNAL done_ALU 		: std_logic;
SIGNAL zero_flag 		: std_logic := '0';
SIGNAL negative_flag : std_logic := '0';

--SINAIS CONTROL UNIT
SIGNAL halt_bool			: std_logic;
SIGNAL mv_position		: integer range 0 to 31 := 0;
SIGNAL jmp_position		: integer range 0 to 31 := 0;
SIGNAL position 			: integer range 0 to 31 := 0;
SIGNAL rA 	 				: std_logic_vector ( 4 downto 0);
SIGNAL rB					: std_logic_vector ( 4 downto 0);
SIGNAL command				: std_logic_vector ( 4 downto 0):= "00000";
SIGNAL zero_flag_uc	 	: std_logic := '0';
SIGNAL negative_flag_uc : std_logic := '0';

-- CONTROLE DO CLOCK
SIGNAL debug_clk500hz : std_logic;
SIGNAL clk_2seg : std_logic;
SIGNAL count_clk : integer := 0;
SIGNAL direction_clk : std_logic := '1';

-- ESTADOS DE EXECUCAO
TYPE state_type IS (idle, reading, fecthing, pre_fetching_mv, fetching_mv, pre_processing_mv, processing_mv, pos_processing_mv, fetching_jmp, processing_jmp, processing, processing_ALU, finishing, halt);
SIGNAL pst_uc	: 	state_type := idle;

begin
RAM_UC: memoria_ram port map (clk=>clk, reset=>reset, r_w=>r_w, endereco=>endereco, leitura=>leitura, escrita=>escrita, dado_30=>mem30);
ALU_UC: alu port map (clk=>clk, opcode=>command, operando1=>rA, operando2=>rB, result=>result, start=>start_ALU, done=>done_ALU, zero_flag=>zero_flag, negative_flag => negative_flag);

zero_flag_led <= zero_flag_uc;
negative_flag_led <= negative_flag_uc;

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
	process (clk)
	begin
		if (clk'event and clk = '1') then
			if (reset = '1') then
				position <= 0;
				rA <= "00000";
				rB <= "00000";
				pst_uc <= idle;
				start_ALU <= '0';
				zero_flag_uc <= '0';
				negative_flag_uc <= '0';
				halt_bool <= '0';
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
						command <= leitura;
						pst_uc <= processing;
					when pre_fetching_mv =>
						r_w <= '1';
						pst_uc <= fetching_mv;
					when fetching_mv =>
						mv_position <= to_integer(unsigned(leitura));
						pst_uc <= pre_processing_mv;
					when pre_processing_mv =>
						endereco <= mv_position;
						r_w <= '1';
						pst_uc <= processing_mv;
					when processing_mv =>
						if (command = "00001") then
							r_w <= '1';
						else
							escrita <= rA;
						end if;
						pst_uc <= pos_processing_mv;
					when pos_processing_mv =>
						if (command = "00001") then
							rA <= leitura;
						else
							r_w <= '0';
						end if;
						pst_uc <= finishing;
					when fetching_jmp =>
						jmp_position <= to_integer(unsigned(leitura));
						endereco <= jmp_position;
						r_w <= '1';
						pst_uc <= processing_jmp;
					when processing_jmp => 
						position <= to_integer(unsigned(leitura));
						pst_uc <= idle;
					when processing =>
							case command is 
								when "00001" => -- MOV A, end
									endereco <= position + 1;
									pst_uc <= pre_fetching_mv;
								when "00010" => -- MOV end, A
									endereco <= position + 1;
									r_w <= '1';
									pst_uc <= pre_fetching_mv;
								when "00011" => -- MOV A, B
									rA <= rB;
									pst_uc <= finishing;	
								when "00100" => -- MOV B, A
									rB <= rA;
									pst_uc <= finishing;
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
								when "01100" => -- JZ
									if(signed(rA) = 0) then
										endereco <= position + 1;
										r_w <= '1';
										pst_uc <= fetching_jmp;
									else
										pst_uc <= finishing;
									end if;						
								when "01101" => -- JN
									if(rA(4) = '1') then
										endereco <= position + 1;
										r_w <= '1';
										pst_uc <= fetching_jmp;
									else
										pst_uc <= finishing;
									end if;	
								when "01110" => -- HALT
									pst_uc <= halt;
								when "01111" => -- JMP
									endereco <= position + 1;
									r_w <= '1';
									pst_uc <= fetching_jmp;
								when "10000" => -- INC A
									start_ALU <= '1';
									pst_uc <= processing_ALU;	
								when "10001" => -- INC B
									start_ALU <= '1';
									pst_uc <= processing_ALU;	
								when "10010" => -- DEC A
									start_ALU <= '1';
									pst_uc <= processing_ALU;	
								when "10011" => -- DEC B
									start_ALU <= '1';
									pst_uc <= processing_ALU;
								
								when others => 
									start_ALU <= '0';
									r_w <= '1';
									pst_uc <= finishing;
							end case;
						when processing_ALU =>
						if (command = "00001" or command = "00010") then
							if (signed(rA) = 0) then
								zero_flag_uc <= '1';
								negative_flag_uc <= '0';
							else 
								negative_flag_uc <= rA(4);
								zero_flag_uc <= '0';
							end if;
						else
							zero_flag_uc <= zero_flag;
							negative_flag_uc <= negative_flag;
						end if;
							if (done_ALU = '1') then
										pst_uc <= finishing;
										if (command = "10011" or command = "10001") then
											rB <= result;
										else
											rA <= result;
										end if;
							end if;							
						when halt =>
							halt_bool <= '1';
							pst_uc <= finishing;
						when finishing =>
							if (position < 31 and halt_bool = '0') then
									position <= position + 1;
									pst_uc <= idle;
							end if;
							--printar no LCD que acabou
						when others =>
							pst_uc <= idle;
				end case;
			end if;
		end if;
	end process;

end arch_control_unit;