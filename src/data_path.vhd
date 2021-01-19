----------------------------------------------------------------------------------
-- Trabalho K&S
-- Alunos: Allan Demetrio, JoÃ£o Carlos, Lucas Karr
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
library work;
use work.k_and_s_pkg.all;

entity data_path is
  port (
    rst_n               : in  std_logic;
    clk                 : in  std_logic;
    branch              : in  std_logic;
    pc_enable           : in  std_logic;
    ir_enable           : in  std_logic;
    addr_sel            : in  std_logic;
    c_sel               : in  std_logic;
    operation           : in  std_logic_vector ( 1 downto 0);
    write_reg_enable    : in  std_logic;
    flags_reg_enable    : in  std_logic;
    decoded_instruction : out decoded_instruction_type;
    zero_op             : out std_logic;
    neg_op              : out std_logic;
    unsigned_overflow   : out std_logic;
    signed_overflow     : out std_logic;
    ram_addr            : out std_logic_vector ( 4 downto 0);
    data_out            : out std_logic_vector (15 downto 0);
    data_in             : in  std_logic_vector (15 downto 0)
  );
end data_path;

architecture rtl of data_path is
  type reg_bank_type is array(natural range <>) of std_logic_vector(15 downto 0);
  signal banco_de_reg : reg_bank_type(0 to 3);
  signal  bus_a : std_logic_vector(15 downto 0);
  signal  bus_b : std_logic_vector(15 downto 0);
  signal  bus_c : std_logic_vector(15 downto 0);
  signal  a_addr :  std_logic_vector(1 downto 0);
  signal  b_addr :  std_logic_vector(1 downto 0);
  signal  c_addr :  std_logic_vector(1 downto 0);
  signal  ula_out :  std_logic_vector(15 downto 0);
  signal  instruction :  std_logic_vector(15 downto 0);
  alias  mem_addr  : std_logic_vector(4 downto 0) is instruction(4 downto 0);
  signal  program_counter : std_logic_vector(4 downto 0);

begin

    --Banco de registradores
    bus_a <= banco_de_reg(conv_integer(a_addr));
    bus_b <= banco_de_reg(conv_integer(b_addr));
    bus_c <= ula_out when (c_sel = '0') else data_in; --Se lembrar na hora de fazer o Control Unit foi pra linha 52 qualquer coisa
    
    --Controle da ULA
    data_out <= bus_a;
    ula_out <=  bus_a and bus_b when (operation = "11") else --AND   11
                bus_a - bus_b when (operation = "10") else   --SUB   10
                bus_a + bus_b when (operation = "01") else   --ADD   01
                bus_a or bus_b;                              --OR    00    

    --Mux RAM
    ram_addr <= mem_addr when (addr_sel = '0') else program_counter;

    --Decoder
    process
    begin
      if ((instruction(15 downto 13)) = "101") then
        c_addr <= instruction(5 downto 4);
        elsif (instruction(15 downto 12) = "1000") then
          c_addr <= instruction(6 downto 5);
      end if ;

      if (instruction(15) = '0')  then
        case (instruction(9 downto 8)) is
          when "01" =>
            decoded_instruction <= I_BRANCH;
          when "10" =>
            decoded_instruction <= I_BZERO;
          when "11" =>
            decoded_instruction <= I_BNEG;
          when others => 
            decoded_instruction <= I_NOP;
        end case;

      elsif (instruction(15) = '1') then
        case (instruction(14 downto 7)) is
          when "00100010" =>  --MOVE
            decoded_instruction <= I_MOVE;
          when "01000010" => --ADD
            decoded_instruction <= I_ADD;
          when "01000100" => --SUB
            decoded_instruction <= I_SUB;
          when "01000110" => --AND
            decoded_instruction <= I_AND;
          when "01001000" => --OR
            decoded_instruction <= I_OR;
          when "00000010" => --LOAD
            decoded_instruction <= I_LOAD;
          when "00000100" => --STORE
            decoded_instruction <= I_STORE;
          when others =>
            decoded_instruction <= I_HALT;
        end case;

      end if ;

    end process;

    --MOVE VAI MEXER COM A E B
    a_addr <= instruction(3 downto 2);
    b_addr <= instruction(1 downto 0);

  process(clk)
  begin
    if (clk'event and clk = '1') then

      --Banco de Registradores
      if (write_reg_enable = '1') then
        banco_de_reg(conv_integer(a_addr)) <= bus_a;
        banco_de_reg(conv_integer(b_addr)) <= bus_b;
        banco_de_reg(conv_integer(c_addr)) <= bus_c;
      end if ;

      --Registrador de Flags
      if (flags_reg_enable = '1') then
        neg_op <= ula_out(15);
        if (ula_out = x"00") then
            zero_op <= '1';
        else
            zero_op <= '0';
      end if;
        
        if (operation = "10") then
            if ((bus_a(15) ='0' and ula_out(15) ='1') or (bus_a(15) ='0' and bus_b(15) ='1') or (bus_b(15) ='1' and ula_out(15) ='1')) then  --A'C+A'B+BC
                unsigned_overflow <= '1';
            else
                unsigned_overflow <= '0';
            end if;
            
            if  ((bus_a(15) ='0' and bus_b(15) ='1' and ula_out(15) ='1') or (bus_a(15) ='1' and bus_b(15) ='0' and ula_out(15) ='0')) then --A'BC + AB'C'
                signed_overflow <= '1';
            else
                signed_overflow <= '0';
            end if;
        end if ;
        
        if (operation = "01") then
            if  ((ula_out(15) = '0' and bus_b(15) = '1') or (ula_out(15) = '0' and bus_a(15)='1') or (bus_b(15) = '1' and bus_a(15) ='1')) then --BC'+AC'+AB
                unsigned_overflow <= '1';
            else
                unsigned_overflow <= '0';
            end if;
            
            if (((bus_a(15) = '0' and bus_b(15) = '0' and ula_out(15) = '1') or (bus_a(15) = '1' and bus_b(15) = '1' and ula_out(15) ='0'))) then  --A'B'C + ABC'
                signed_overflow <= '1';
            else
                signed_overflow <= '0';
            end if;
        end if ;
      end if ;

      --Intepretador de InstruÃ§Ãµes
      if (ir_enable = '1') then
        instruction <= data_in;
      else
        instruction <= "0000000000000000";
      end if;
      
      --Program Counter
      if ((branch = '0') and (pc_enable = '1')) then
        program_counter <= program_counter + 1;
      elsif ((branch = '1') and (pc_enable = '1')) then
        program_counter <= mem_addr;
      end if ;  
    end if ;
  
  end process;

end rtl;