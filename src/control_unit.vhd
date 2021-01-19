----------------------------------------------------------------------------------
-- Trabalho K&S
-- Alunos: Allan Demetrio, João Carlos, Lucas Karr
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.k_and_s_pkg.all;

entity control_unit is
  port (
    rst_n               : in  std_logic;
    clk                 : in  std_logic;
    branch              : out std_logic;
    pc_enable           : out std_logic;
    ir_enable           : out std_logic;
    write_reg_enable    : out std_logic;
    addr_sel            : out std_logic;
    c_sel               : out std_logic;
    operation           : out std_logic_vector (1 downto 0);
    flags_reg_enable    : out std_logic;
    decoded_instruction : in  decoded_instruction_type;
    zero_op             : in  std_logic;
    neg_op              : in  std_logic;
    unsigned_overflow   : in  std_logic;
    signed_overflow     : in  std_logic;
    ram_write_enable    : out std_logic;
    halt                : out std_logic
    );
end control_unit;

architecture rtl of control_unit is
    type estados is (
    FETCH,
    DECODE,
    PROX,
    LOAD,
    STORE,
    MOVE,
    ADD,
    SUB,
    ANDI,
    ORI,
    BRANCH,
    BZERO,
    BNEG,
    NOP,
    HALT
    );
    signal estado_atual : estados;
    signal prox_estado : estados;

begin

    process (clk)
        begin
            if (clk'event and clk='1') then
                if (rst_n='1') then
                    estado_atual <= FETCH;
                else
                    estado_atual <= prox_estado;
                end if;
            end if;
    end process;

    process(clk)
        begin
            prox_estado <= estado_atual;
            case(estado_atual) is
                when FETCH =>
                    ir_enable <= '1';
                    flag_enable <= '0';
                    pc_enable <='0';
                    write_reg_enable <='0';
                    prox_estado <= DECODE;

                when DECODE =>
                    case decoded_instruction is

                        when I_NOP =>
                            prox_estado <= NOP;

                        when others =>
                            prox_estado <= HALT;
                            
                    
                    end case;
                
                when NOP =>
                    ir_enable <= '0';
                    flag_enable <= '0';
                    pc_enable <='1';
                    write_reg_enable <='0';
                    prox_estado <= PROX;

                when HALT =>
                    ir_enable <= '0';
                    flag_enable <= '0';
                    pc_enable <='0';
                    write_reg_enable <='0';
                    halt <= '1';
                    prox_estado <= HALT;                                  
            
                when others =>  --PROX
                    ir_enable <= '0';
                    flag_enable <= '0';
                    pc_enable <='1';
                    write_reg_enable <='0';
                    prox_estado <= FETCH;

            end case ;
    end process ;

--process to test environment ... remove this
--    main: process(clk, rst_n)
--    begin
--        if (rst_n = '0') then
--            counter <= (others => '0');
--        elsif (clk'event and clk='1') then
--            counter <= counter + 1;
--        end if;
--    end process main;
--    halt <= '1' when counter = x"5f" else '0';
-- remove until here....
end rtl;