----------------------------------------------------------------------------------
-- Trabalho K&S
-- Alunos: Allan Demetrio, João Carlos, Lucas Karr
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
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
  signal banco_de_reg : reg_bank_type(0 to 15);
  signal  bus_a : std_logic_vector(15 downto 0);
  signal  bus_b : std_logic_vector(15 downto 0);
  signal  bus_c : std_logic_vector(15 downto 0);
  signal  a_addr :  std_logic_vector(1 downto 0);
  signal  b_addr :  std_logic_vector(1 downto 0);
  signal  c_addr :  std_logic_vector(1 downto 0);
  signal  ula_out :  std_logic_vector(15 downto 0);
  signal  instruction :  std_logic_vector(15 downto 0);
  signal  mem_addr  : std_logic_vector(4 downto 0);
  signal  program_counter : std_logic_vector(4 downto 0);
  signal  branch_out  : std_logic_vector(4 downto 0);

begin
    --ram_addr <= (others => '0'); just to avoid messaging from test... remove this line
    --Controle da ULA
    data_out <= bus_a;
    neg_op <= ula_out(15);
    zero_op <= '1' when ula_out == x"00" else '0';
    ula_out <=  bus_a and bus_b when operation = "11" else   --AND   11
                bus_a - bus_b when operation = "10" else  --SUB   10
                bus_a + bus_b when operation = "01" else   --ADD   01
                bus_a OR bus_b;                          --OR    00
    bus_c <= ula_out when c_sel = '0' else data_in;   --Se lembrar na hora de fazer o Control Unit
    
    --Controle do PC
    ram_addr <= mem_addr when addr_sel == '0' else program_counter;
    branch_out <= program_counter+1 when branch == '0' else mem_addr;
    program_counter <= branch_out when pc_enable == '1' else '0';




end rtl;

