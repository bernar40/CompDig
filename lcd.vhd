library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
USE IEEE.std_logic_unsigned.ALL;
use IEEE.std_logic_arith.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lcd is
	PORT(
		clk    	: IN STD_LOGIC;
		opcode 	: IN STD_LOGIC_VECTOR ( 4 downto 0);
		endereco_jmp : IN integer range 0 to 31;
		endereco_mv : IN integer range 0 to 31;
		lcd_rw 	: OUT STD_LOGIC;
		lcd_rs 	: OUT STD_LOGIC;
		lcd_e  	: OUT STD_LOGIC;
		sf_d 	 	: OUT STD_LOGIC_VECTOR ( 11 downto 8));
end lcd;

architecture arch_lcd of lcd is

signal clk_500HZ : STD_LOGIC;
signal count_clk : INTEGER := 0;
signal direction_clk : STD_LOGIC := '1';

signal mv_position_dezena : INTEGER;
signal mv_position_unidade : INTEGER;
signal jmp_position_dezena : INTEGER;
signal jmp_position_unidade : INTEGER;


type lcd_type is array(0 to 10) of STD_LOGIC_VECTOR(7 downto 0);
signal lcd_array : lcd_type := (
		0 => "10100000", 
		1 => "10100000", 
		2 => "10100000",
		others => "10100000"
	);
-- LCD steps
type state_type is (initialization_st_1, initialization_st_2, initialization_st_3, initialization_st_4, initialization_st_5, 
						  initialization_st_6, initialization_st_7, initialization_st_8, initialization_st_9,
						  configuration_st_1, configuration_st_2, configuration_st_3, configuration_st_4, configuration_st_5, 
						  configuration_st_6, configuration_st_7, configuration_st_8, configuration_st_9, configuration_st_10,
						  configuration_st_11, configuration_st_12, configuration_st_13, configuration_st_14, configuration_st_15,
						  configuration_st_16, write_st_1, write_st_2, write_st_3, write_st_4, write_st_5, write_st_6,
						  write_st_7,write_st_8,write_st_9, write_st_10, write_st_11, write_st_12, write_st_13,
						  write_st_14, write_st_15, write_st_16, write_st_17, write_st_18, write_st_19, write_st_20, 
						  write_st_21, write_st_22, write_st_23, write_st_24, write_st_25, write_st_26, write_st_27,
						  write_st_28, write_st_29, write_st_30, write_st_31, write_st_32, write_st_33, write_st_34,
						  write_st_35, write_st_36, write_st_37, write_st_38, write_st_39, write_st_40, write_st_41,
						  write_st_42, write_st_43, write_st_44, write_st_45, write_st_46, write_st_47, finish);
signal pst : state_type := initialization_st_1;
-- Initialization signals
signal count_initialization : INTEGER := 0;

begin

-- Processo que transforma o clock de 50MHZ em 500HZ -OK
	process (clk)
	begin
		if (clk'event and clk = '1') then
			if (count_clk < 250000 and direction_clk = '1') then
					clk_500HZ <= '0';
					count_clk <= count_clk + 1;
			elsif (count_clk < 500000 and direction_clk = '1') then
					clk_500HZ <= '1';
					count_clk <= count_clk + 1;
			else 
					count_clk <= 0;
			end if;
		end if;
	end process;
	
	process (clk_500HZ)
	begin
		if (CLK_500HZ'event and CLK_500HZ = '1') then
			case pst is 
				-- Casos de inicialização
				when initialization_st_1 => lcd_rs <= '0' ; lcd_rw <= '0'; lcd_e <= '1'; pst <= initialization_st_2;
				when initialization_st_2 => lcd_e <= '0';  sf_d(11 downto 8) <= "0011"; pst <= initialization_st_3;
				when initialization_st_3 => lcd_e <= '1';  pst <= initialization_st_4;
				when initialization_st_4 => lcd_e <= '0'; sf_d(11 downto 8) <= "0011"; pst <= initialization_st_5;
				when initialization_st_5 => lcd_e <= '1'; pst <= initialization_st_6;
				when initialization_st_6 => lcd_e <= '0'; sf_d(11 downto 8) <= "0011"; pst <= initialization_st_7;
				when initialization_st_7 => lcd_e <= '1'; pst <= initialization_st_8;
				when initialization_st_8 => lcd_e <= '0'; sf_d(11 downto 8) <= "0010"; pst <= initialization_st_9;
				when initialization_st_9 => lcd_e <= '1'; pst <= configuration_st_1;
				
				-- Casos de configuração				
				when configuration_st_1 =>  lcd_e <= '0'; sf_d(11 downto 8) <= "0010"; pst <= configuration_st_2;
				when configuration_st_2 =>  lcd_e <= '1'; pst <= configuration_st_3;
				when configuration_st_3 =>  lcd_e <= '0'; sf_d(11 downto 8) <= "1000"; pst <= configuration_st_4;
				when configuration_st_4 =>  lcd_e <= '1'; pst <= configuration_st_5;
				when configuration_st_5 =>  lcd_e <= '0'; sf_d(11 downto 8) <= "0000"; pst <= configuration_st_6;
				when configuration_st_6 =>  lcd_e <= '1'; pst <= configuration_st_7;
				when configuration_st_7 =>  lcd_e <= '0'; sf_d(11 downto 8) <= "0110"; pst <= configuration_st_8;
				when configuration_st_8 =>  lcd_e <= '1'; pst <= configuration_st_9;
				when configuration_st_9 =>  lcd_e <= '0'; sf_d(11 downto 8) <= "0000"; pst <= configuration_st_10;
				when configuration_st_10 => lcd_e <= '1'; pst <= configuration_st_11;
				when configuration_st_11 => lcd_e <= '0'; sf_d(11 downto 8) <= "1100"; pst <= configuration_st_12;
				when configuration_st_12 => lcd_e <= '1'; pst <= configuration_st_13;
				when configuration_st_13 => lcd_e <= '0'; sf_d(11 downto 8) <= "0000"; pst <= configuration_st_14;
				when configuration_st_14 => lcd_e <= '1'; pst <= configuration_st_15;
				when configuration_st_15 => lcd_e <= '0'; sf_d(11 downto 8) <= "0001"; pst <= configuration_st_16;
				when configuration_st_16 => lcd_e <= '1'; pst <= write_st_1;


				when write_st_1 =>  lcd_e <= '0'; lcd_rs <= '1' ; lcd_rw <= '0'; pst <= write_st_2;
				when write_st_2 =>  lcd_e <= '0'; pst <= write_st_3;
				when write_st_3 =>  lcd_e <= '0'; sf_d (11 downto 8) <= lcd_array(0)(7 downto 4); pst <= write_st_4;
				when write_st_4 =>  lcd_e <= '1'; pst <= write_st_5;
				when write_st_5 =>  lcd_e <= '0'; sf_d (11 downto 8) <= lcd_array(0)(3 downto 0); pst <= write_st_6;  
				when write_st_6 =>  lcd_e <= '1'; pst <= write_st_7; 
				when write_st_7 =>  lcd_e <= '0'; sf_d (11 downto 8) <= lcd_array(1)(7 downto 4); pst <= write_st_8;
				when write_st_8 =>  lcd_e <= '1'; pst <= write_st_9;
				when write_st_9 =>  lcd_e <= '0'; sf_d (11 downto 8) <= lcd_array(1)(3 downto 0); pst <= write_st_10;
				when write_st_10 => lcd_e <= '1'; pst <= write_st_11;
				when write_st_11 => lcd_e <= '0'; sf_d (11 downto 8) <= lcd_array(2)(7 downto 4); pst <= write_st_12;
				when write_st_12 => lcd_e <= '1'; pst <= write_st_13;
				when write_st_13 => lcd_e <= '0'; sf_d (11 downto 8) <= lcd_array(2)(3 downto 0); pst <= write_st_14;
				when write_st_14 => lcd_e <= '1'; pst <= write_st_15;
				when write_st_15 => lcd_e <= '0'; sf_d (11 downto 8) <= lcd_array(3)(7 downto 4); pst <= write_st_16;
				when write_st_16 => lcd_e <= '1'; pst <= write_st_17;
				when write_st_17 => lcd_e <= '0'; sf_d (11 downto 8) <= lcd_array(3)(3 downto 0); pst <= write_st_18;
				when write_st_18 => lcd_e <= '1'; pst <= write_st_19;
				when write_st_19 => lcd_e <= '0'; sf_d (11 downto 8) <= lcd_array(4)(7 downto 4); pst <= write_st_20;
				when write_st_20 => lcd_e <= '1'; pst <= write_st_21;
				when write_st_21 => lcd_e <= '0'; sf_d (11 downto 8) <= lcd_array(4)(3 downto 0); pst <= write_st_22;
				when write_st_22 => lcd_e <= '1'; pst <= write_st_23;
				when write_st_23 => lcd_e <= '0'; sf_d (11 downto 8) <= lcd_array(5)(7 downto 4); pst <= write_st_24;
				when write_st_24 => lcd_e <= '1'; pst <= write_st_25;
				when write_st_25 => lcd_e <= '0'; sf_d (11 downto 8) <= lcd_array(5)(3 downto 0); pst <= write_st_26;
				when write_st_26 => lcd_e <= '1'; pst <= write_st_27;
				when write_st_27 => lcd_e <= '0'; sf_d (11 downto 8) <= lcd_array(6)(7 downto 4); pst <= write_st_28;
				when write_st_28 => lcd_e <= '1'; pst <= write_st_29;
				when write_st_29 => lcd_e <= '0'; sf_d (11 downto 8) <= lcd_array(6)(3 downto 0); pst <= write_st_30;
				when write_st_30 => lcd_e <= '1'; pst <= write_st_31;
				when write_st_31 => lcd_e <= '0'; sf_d (11 downto 8) <= lcd_array(7)(7 downto 4); pst <= write_st_32;
				when write_st_32 => lcd_e <= '1'; pst <= write_st_33;
				when write_st_33 => lcd_e <= '0'; sf_d (11 downto 8) <= lcd_array(7)(3 downto 0); pst <= write_st_34;
				when write_st_34 => lcd_e <= '1'; pst <= write_st_35;
				when write_st_35 => lcd_e <= '0'; sf_d (11 downto 8) <= lcd_array(8)(7 downto 4); pst <= write_st_36;
				when write_st_36 => lcd_e <= '1'; pst <= write_st_37;
				when write_st_37 => lcd_e <= '0'; sf_d (11 downto 8) <= lcd_array(8)(3 downto 0); pst <= write_st_38;
				when write_st_38 => lcd_e <= '1'; pst <= write_st_39;
				when write_st_39 => lcd_e <= '0'; sf_d (11 downto 8) <= lcd_array(9)(7 downto 4); pst <= write_st_40;
				when write_st_40 => lcd_e <= '1'; pst <= write_st_41;
				when write_st_41 => lcd_e <= '0'; sf_d (11 downto 8) <= lcd_array(9)(3 downto 0); pst <= write_st_42;
				when write_st_42 => lcd_e <= '1'; pst <= write_st_43;
				when write_st_43 => lcd_e <= '0'; sf_d (11 downto 8) <= lcd_array(10)(7 downto 4); pst <= write_st_44;
				when write_st_44 => lcd_e <= '1'; pst <= write_st_45;
				when write_st_45 => lcd_e <= '0'; sf_d (11 downto 8) <= lcd_array(10)(3 downto 0); pst <= write_st_46;
				when write_st_46 => lcd_e <= '1'; pst <= write_st_47;
				when write_st_47 => lcd_e <= '0'; pst <= finish;
				when finish => pst <=  initialization_st_1;
				when others => pst <=  initialization_st_1;
			end case;
		end if;
	end process;
	
	
	process(CLK_500HZ, opcode)
		begin
		 if (CLK_500HZ'event and CLK_500HZ = '1') then
			if endereco_mv < 10 then
				mv_position_dezena <= 0;
				mv_position_unidade <= endereco_mv;
			else 
				if endereco_mv >= 10 and endereco_mv < 20 then
					mv_position_dezena <= 1;
					mv_position_unidade <= endereco_mv - 10;
				elsif endereco_mv >= 20 and endereco_mv < 30 then
					mv_position_dezena <= 2;
					mv_position_unidade <= endereco_mv - 20;
				else
					mv_position_dezena <= 3;
					mv_position_unidade <= endereco_mv - 30;
				end if;
			end if;
			if endereco_jmp < 10 then
				jmp_position_dezena <= 0;
				jmp_position_unidade <= endereco_jmp;
			else 
				if endereco_jmp >= 10 and endereco_jmp < 20 then
					jmp_position_dezena <= 1;
					jmp_position_unidade <= endereco_jmp - 10;
				elsif endereco_jmp >= 20 and endereco_jmp < 30 then
					jmp_position_dezena <= 2;
					jmp_position_unidade <= endereco_jmp - 20;
				else
					jmp_position_dezena <= 3;
					jmp_position_unidade <= endereco_jmp - 30;
				end if;
			end if;
			case opcode is
				when "00001" =>  -- MOV A, [XX]
					lcd_array(0)  <= "01001101";  -- M
					lcd_array(1)  <= "01001111";  -- O
					lcd_array(2)  <= "01010110";  -- V
					lcd_array(3)  <= "10100000";  --  
					lcd_array(4)  <= "01000001";  -- A
					lcd_array(5)  <= "00101100";  -- ,
					lcd_array(6)  <= "10100000";  --  
					lcd_array(7)  <= "01011011";  -- [
					lcd_array(8)(7 downto 4) <= "0011";
					lcd_array(8)(3 downto 0) <= conv_std_logic_vector(mv_position_dezena, 4);
					lcd_array(9)(7 downto 4) <= "0011";
					lcd_array(9)(3 downto 0) <= conv_std_logic_vector(mv_position_unidade, 4);
					lcd_array(10) <= "01011101";  -- ]
				when "00010" =>  -- MOV [XX], A
					lcd_array(0)  <= "01001101";  -- M
					lcd_array(1)  <= "01001111";  -- O
					lcd_array(2)  <= "01010110";  -- V
					lcd_array(3)  <= "10100000";  --  
					lcd_array(4)  <= "01011011";  -- [
					lcd_array(5)(7 downto 4) <= "0011";
					lcd_array(5)(3 downto 0) <= conv_std_logic_vector(mv_position_dezena, 4);
					lcd_array(6)(7 downto 4) <= "0011";
					lcd_array(6)(3 downto 0) <= conv_std_logic_vector(mv_position_unidade, 4);
					lcd_array(7)  <= "01011101";  -- ]
					lcd_array(8)  <= "00101100";  -- ,
					lcd_array(9)  <= "10100000";  --  
					lcd_array(10) <= "01000001";  -- A
				when "00011" =>  -- MOV A, B
					lcd_array(0)  <= "01001101";  -- M
					lcd_array(1)  <= "01001111";  -- O
					lcd_array(2)  <= "01010110";  -- V
					lcd_array(3)  <= "10100000";  --  
					lcd_array(4)  <= "01000001";  -- A
					lcd_array(5)  <= "00101100";  -- ,
					lcd_array(6)  <= "10100000";  --  
					lcd_array(7)  <= "01000010";  -- B
					lcd_array(8)  <= "10100000";  --  
					lcd_array(9)  <= "10100000";  --  
					lcd_array(10) <= "10100000";  --    
				when "00100" =>  -- MOV B, A
					lcd_array(0)  <= "01001101";  -- M
					lcd_array(1)  <= "01001111";  -- O
					lcd_array(2)  <= "01010110";  -- V
					lcd_array(3)  <= "10100000";  --  
					lcd_array(4)  <= "01000010";  -- B
					lcd_array(5)  <= "00101100";  -- ,
					lcd_array(6)  <= "10100000";  --  
					lcd_array(7)  <= "01000001";  -- A
					lcd_array(8)  <= "10100000";  --  
					lcd_array(9)  <= "10100000";  --  
					lcd_array(10) <= "10100000";  --   
				when "00101" =>  -- ADD A, B
					lcd_array(0)  <= "01000001";  -- A
					lcd_array(1)  <= "01000100";  -- D
					lcd_array(2)  <= "01000100";  -- D
					lcd_array(3)  <= "10100000";  --  
					lcd_array(4)  <= "01000001";  -- A
					lcd_array(5)  <= "00101100";  -- ,
					lcd_array(6)  <= "10100000";  --  
					lcd_array(7)  <= "01000010";  -- B
					lcd_array(8)  <= "10100000";  --  
					lcd_array(9)  <= "10100000";  --  
					lcd_array(10) <= "10100000";  --   
				when "00110" =>  -- SUB A, B
					lcd_array(0)  <= "01010011";  -- S
					lcd_array(1)  <= "01010101";  -- U
					lcd_array(2)  <= "01000010";  -- B
					lcd_array(3)  <= "10100000";  --  
					lcd_array(4)  <= "01000001";  -- A
					lcd_array(5)  <= "00101100";  -- ,
					lcd_array(6)  <= "10100000";  --  
					lcd_array(7)  <= "01000010";  -- B
					lcd_array(8)  <= "10100000";  --  
					lcd_array(9)  <= "10100000";  --  
					lcd_array(10) <= "10100000";  --    
				when "00111" =>  -- AND A, B
					lcd_array(0)  <= "01000001";  -- A
					lcd_array(1)  <= "01001110";  -- N
					lcd_array(2)  <= "01000100";  -- D
					lcd_array(3)  <= "10100000";  --  
					lcd_array(4)  <= "01000001";  -- A
					lcd_array(5)  <= "00101100";  -- ,
					lcd_array(6)  <= "10100000";  --  
					lcd_array(7)  <= "01000010";  -- B
					lcd_array(8)  <= "10100000";  --  
					lcd_array(9)  <= "10100000";  --  
					lcd_array(10) <= "10100000";  --   
				when "01000" =>  -- OR A, B
					lcd_array(0)  <= "01001111";  -- O
					lcd_array(1)  <= "01010010";  -- R
					lcd_array(2)  <= "10100000";  --  
					lcd_array(3)  <= "01000001";  -- A
					lcd_array(4)  <= "00101100";  -- ,
					lcd_array(5)  <= "10100000";  --  
					lcd_array(6)  <= "01000010";  -- B
					lcd_array(7)  <= "10100000";  --  
					lcd_array(8)  <= "10100000";  --  
					lcd_array(9)  <= "10100000";  --  
					lcd_array(10) <= "10100000";  --   
				when "01001" =>  -- XOR A, B
					lcd_array(0)  <= "01011000";  -- X
					lcd_array(1)  <= "01001111";  -- O
					lcd_array(2)  <= "01010010";  -- R
					lcd_array(3)  <= "10100000";  --  
					lcd_array(4)  <= "01000001";  -- A
					lcd_array(5)  <= "00101100";  -- ,
					lcd_array(6)  <= "10100000";  --  
					lcd_array(7)  <= "01000010";  -- B
					lcd_array(8)  <= "10100000";  --  
					lcd_array(9)  <= "10100000";  --  
					lcd_array(10) <= "10100000";  --  
				when "01010" =>  -- NOT A
					lcd_array(0)  <= "01001110";  -- N
					lcd_array(1)  <= "01001111";  -- O
					lcd_array(2)  <= "01010100";  -- T
					lcd_array(3)  <= "10100000";  --  
					lcd_array(4)  <= "01000001";  -- A
					lcd_array(5)  <= "10100000";  --  
					lcd_array(6)  <= "10100000";  --  
					lcd_array(7)  <= "10100000";  --  
					lcd_array(8)  <= "10100000";  --  
					lcd_array(9)  <= "10100000";  --  
					lcd_array(10) <= "10100000";  --  
				when "01011" =>  -- NAND A, B
					lcd_array(0)  <= "01001110";  -- N
					lcd_array(1)  <= "01000001";  -- A
					lcd_array(2)  <= "01001110";  -- N
					lcd_array(3)  <= "01000100";  -- D
					lcd_array(4)  <= "10100000";  --  
					lcd_array(5)  <= "01000001";  -- A
					lcd_array(6)  <= "00101100";  -- ,
					lcd_array(7)  <= "10100000";  --  
					lcd_array(8)  <= "01000010";  -- B
					lcd_array(9)  <= "10100000";  --  
					lcd_array(10) <= "10100000";  --   
				when "01100" =>  -- JZ [XX]
					lcd_array(0)  <= "01001010";  -- J
					lcd_array(1)  <= "01011010";  -- Z
					lcd_array(2)  <= "10100000";  --  
					lcd_array(3)  <= "01011011";  -- [
					lcd_array(4)(7 downto 4) <= "0011";
					lcd_array(4)(3 downto 0) <= conv_std_logic_vector(jmp_position_dezena, 4);
					lcd_array(5)(7 downto 4) <= "0011";
					lcd_array(5)(3 downto 0) <= conv_std_logic_vector(jmp_position_unidade, 4);
					lcd_array(6)  <= "01011101";  -- ]
					lcd_array(7)  <= "10100000";  --  
					lcd_array(8)  <= "10100000";  --  
					lcd_array(9)  <= "10100000";  --  
					lcd_array(10) <= "10100000";  --  
				when "01101" =>  -- JN [XX]
					lcd_array(0)  <= "01001010";  -- J
					lcd_array(1)  <= "01001110";  -- N
					lcd_array(2)  <= "10100000";  --  
					lcd_array(3)  <= "01011011";  -- [
					lcd_array(4)(7 downto 4) <= "0011";
					lcd_array(4)(3 downto 0) <= conv_std_logic_vector(jmp_position_dezena, 4);
					lcd_array(5)(7 downto 4) <= "0011";
					lcd_array(5)(3 downto 0) <= conv_std_logic_vector(jmp_position_unidade, 4);
					lcd_array(6)  <= "01011101";  -- ]
					lcd_array(7)  <= "10100000";  --  
					lcd_array(8)  <= "10100000";  --  
					lcd_array(9)  <= "10100000";  --  
					lcd_array(10) <= "10100000";  --  
				when "01110" =>  -- HALT
					lcd_array(0)  <= "01001000";  -- H
					lcd_array(1)  <= "01000001";  -- A
					lcd_array(2)  <= "01001100";  -- L
					lcd_array(3)  <= "01010100";  -- T
					lcd_array(4)  <= "10100000";  --  
					lcd_array(5)  <= "10100000";  --  
					lcd_array(6)  <= "10100000";  --  
					lcd_array(7)  <= "10100000";  --  
					lcd_array(8)  <= "10100000";  --  
					lcd_array(9)  <= "10100000";  --  
					lcd_array(10) <= "10100000";  --  
				when "01111" =>  -- JMP [XX]
					lcd_array(0)  <= "01001010";  -- J
					lcd_array(1)  <= "01001101";  -- M
					lcd_array(2)  <= "01010000";  -- P
					lcd_array(3)  <= "10100000";  --  
					lcd_array(4)  <= "01011011";  -- [
					lcd_array(5)(7 downto 4) <= "0011";
					lcd_array(5)(3 downto 0) <= conv_std_logic_vector(jmp_position_dezena, 4);
					lcd_array(6)(7 downto 4) <= "0011";
					lcd_array(6)(3 downto 0) <= conv_std_logic_vector(jmp_position_unidade, 4);
					lcd_array(7)  <= "01011101";  -- ]
					lcd_array(8)  <= "10100000";  --  
					lcd_array(9)  <= "10100000";  --  
					lcd_array(10) <= "10100000";  --  
				when "10000" =>  -- INC A
					lcd_array(0)  <= "01001001";  -- I
					lcd_array(1)  <= "01001110";  -- N
					lcd_array(2)  <= "01000011";  -- C
					lcd_array(3)  <= "10100000";  --  
					lcd_array(4)  <= "01000001";  -- A
					lcd_array(5)  <= "10100000";  --  
					lcd_array(6)  <= "10100000";  --  
					lcd_array(7)  <= "10100000";  --  
					lcd_array(8)  <= "10100000";  --  
					lcd_array(9)  <= "10100000";  --  
					lcd_array(10) <= "10100000";  --  
				when "10001" =>  -- INC B
					lcd_array(0)  <= "01001001";  -- I
					lcd_array(1)  <= "01001110";  -- N
					lcd_array(2)  <= "01000011";  -- C
					lcd_array(3)  <= "10100000";  --  
					lcd_array(4)  <= "01000010";  -- B
					lcd_array(5)  <= "10100000";  --  
					lcd_array(6)  <= "10100000";  --  
					lcd_array(7)  <= "10100000";  --  
					lcd_array(8)  <= "10100000";  --  
					lcd_array(9)  <= "10100000";  --  
					lcd_array(10) <= "10100000";  --  
				when "10010" =>  -- DEC A
					lcd_array(0)  <= "01000100";  -- D
					lcd_array(1)  <= "01000101";  -- E
					lcd_array(2)  <= "01000011";  -- C
					lcd_array(3)  <= "10100000";  --  
					lcd_array(4)  <= "01000001";  -- A
					lcd_array(5)  <= "10100000";  --  
					lcd_array(6)  <= "10100000";  --  
					lcd_array(7)  <= "10100000";  --  
					lcd_array(8)  <= "10100000";  --  
					lcd_array(9)  <= "10100000";  --  
					lcd_array(10) <= "10100000";  --   
				when "10011" =>  -- DEC B
					lcd_array(0)  <= "01000100";  -- D
					lcd_array(1)  <= "01000101";  -- E
					lcd_array(2)  <= "01000011";  -- C
					lcd_array(3)  <= "10100000";  --  
					lcd_array(4)  <= "01000010";  -- B
					lcd_array(5)  <= "10100000";  --  
					lcd_array(6)  <= "10100000";  --  
					lcd_array(7)  <= "10100000";  --  
					lcd_array(8)  <= "10100000";  --  
					lcd_array(9)  <= "10100000";  --  
					lcd_array(10) <= "10100000";  --  
				when others =>
					lcd_array(0)  <= "10100000";  -- 
					lcd_array(1)  <= "10100000";  -- 
					lcd_array(2)  <= "10100000";  -- 
					lcd_array(3)  <= "10100000";  --  
					lcd_array(4)  <= "10100000";  -- 
					lcd_array(5)  <= "10100000";  --  
					lcd_array(6)  <= "10100000";  --  
					lcd_array(7)  <= "10100000";  --  
					lcd_array(8)  <= "10100000";  --  
					lcd_array(9)  <= "10100000";  --  
					lcd_array(10) <= "10100000";  --  
			end case;
		end if;
	end process;
	
end arch_lcd;


