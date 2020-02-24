
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

ENTITY GAME_LOGIC IS
	generic (
	--DEFAULT---1280x1024 @ 60 Hz pixel clock 108 MHz
	FRONT_PORCH_H : INTEGER := 48;
	SYNC_PULSE_H : INTEGER := 112;
	BACK_PORCH_H : INTEGER := 248;
	RES_H : INTEGER := 1280;
	FRONT_PORCH_V : INTEGER := 1;
	SYNC_PULSE_V : INTEGER := 3;
	BACK_PORCH_V : INTEGER := 38;
	RES_V : INTEGER := 1024
);
	
PORT(
	CLK : in std_logic;
	HPOS_IN: IN UNSIGNED (11 downto 0);
	VPOS_IN: IN UNSIGNED (11 downto 0);
	KEYS: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	S: IN STD_LOGIC_VECTOR(5 downto 0);
	P1_Pos : IN STD_LOGIC_VECTOR(0 to 7);
	P2_Pos : IN STD_LOGIC_VECTOR(0 to 7);
	Score_1, Score_2: OUT STD_LOGIC_VECTOR(3 downto 0);
	DRAW : out std_logic
	
);
END GAME_LOGIC;


ARCHITECTURE MAIN OF GAME_LOGIC IS

CONSTANT BLANK_H: INTEGER := (FRONT_PORCH_H + SYNC_PULSE_H + BACK_PORCH_H);
CONSTANT BLANK_V: INTEGER := (FRONT_PORCH_V + SYNC_PULSE_V + BACK_PORCH_V);

SIGNAL Square_X1: INTEGER RANGE (BLANK_H) TO (BLANK_H + RES_H) := BLANK_H;
SIGNAL Square_Y1: INTEGER RANGE BLANK_V TO (BLANK_V + RES_V-100):=(BLANK_V + RES_V/2 - 50);
SIGNAL Points_1: UNSIGNED(3 downto 0):="0000";
SIGNAL Square_X2: INTEGER RANGE (BLANK_H) TO (BLANK_H + RES_H) :=(BLANK_H + RES_H - 15);
SIGNAL Square_Y2: INTEGER RANGE (BLANK_V) TO (BLANK_V + RES_V):=(BLANK_V + RES_V/2 - 50);
SIGNAL Points_2: UNSIGNED(3 downto 0):="0000";
SIGNAL Circle_X: INTEGER RANGE (BLANK_H) TO (BLANK_H + RES_H):=(BLANK_H + RES_H/2);
SIGNAL Circle_Y: INTEGER RANGE (BLANK_V) TO (BLANK_V + RES_V):=(BLANK_V + RES_V/2);
SIGNAL Circle_D: STD_LOGIC_VECTOR(1 downto 0):="11";
SIGNAL HPOS: INTEGER RANGE 0 TO ((FRONT_PORCH_H + SYNC_PULSE_H + BACK_PORCH_H) + RES_H):=0;
SIGNAL VPOS: INTEGER RANGE 0 TO ((FRONT_PORCH_V + SYNC_PULSE_V + BACK_PORCH_V) + RES_V):=0;
 BEGIN
	HPOS <= to_integer(HPOS_IN);
	VPOS <= to_integer(VPOS_IN);
	Score_1 <= std_logic_vector(Points_1);
	Score_2 <= std_logic_vector(Points_2);
	PROCESS(HPOS, VPOS)
	BEGIN
		IF(((HPOS - Circle_X)*(HPOS - Circle_X) + (VPOS - Circle_Y)*(VPOS - Circle_Y)) < 144)THEN
			DRAW<='1';
		ELSIF(HPOS>Square_X1 AND HPOS<(Square_X1+15) AND VPOS>Square_Y1 AND VPOS<(Square_Y1+100))THEN
			DRAW<='1';
		ELSIF(HPOS>Square_X2 AND HPOS<(Square_X2+15) AND VPOS>Square_Y2 AND VPOS<(Square_Y2+100))THEN
			DRAW<='1';
		ELSE
			DRAW<='0';
		END IF;
	END PROCESS;
	PROCESS(CLK)
	 BEGIN
		IF(CLK'EVENT AND CLK='1')THEN
			
			IF(Points_1 /= 15 AND Points_2 /= 15 AND S(4)='0') THEN
				IF(S(2)='1')THEN
					IF(Circle_D(1) ='1')THEN
						IF(S(3)='1') THEN
							Circle_X<=Circle_X+1;
						ELSE
							Circle_X<=Circle_X+6;
						END IF;
					END IF;
					IF(Circle_D(1)='0' )THEN
						IF(S(3)='1') THEN
							Circle_X<=Circle_X-1;
						ELSE
							Circle_X<=Circle_X-6;
						END IF;
					END IF;
					IF(Circle_D(0)='0')THEN
						IF(S(3)='1') THEN
							Circle_Y<=Circle_Y-1;
						ELSE
							Circle_Y<=Circle_Y-6;
						END IF;
					END IF;
					IF(Circle_D(0)='1')THEN
						IF(S(3)='1') THEN
							Circle_Y<=Circle_Y+1;
						ELSE
							Circle_Y<=Circle_Y+6;
						END IF;
					END IF;
					
					IF(Circle_X<(BLANK_H + 27)) THEN
						IF(Circle_Y > (Square_Y1 - 21) and Circle_Y < (Square_Y1 + 101)) THEN
						IF((KEYS(3) = '0' OR KEYS(2) = '0') AND (Square_Y1 > 40)) THEN
						Circle_D(0) <= NOT KEYS(2);
						END IF;
						Circle_D(1) <= '1';
						Circle_X<= (BLANK_H + 27);
						ELSIF(Circle_X<(BLANK_H + 12)) THEN
							Circle_D(1) <= '1';
							Circle_X <= (BLANK_H + RES_H/2);
							Points_2 <= Points_2 + 1;
						END IF;
					END IF;
					IF(Circle_X>(BLANK_H + RES_H - 27)) THEN
						IF(Circle_Y > (Square_Y2 - 12) and Circle_Y < (Square_Y2 + 101)) THEN
							IF((KEYS(1) = '0' OR KEYS(0) = '0') AND (Square_Y2 > (BLANK_V))) THEN
								Circle_D(0) <= NOT KEYS(0);
							END IF;
							Circle_D(1) <= '0';
							Circle_X <= (BLANK_H + RES_H - 27);
						ELSIF(Circle_X>(BLANK_H + RES_H - 12)) THEN
							Circle_D(1) <= '0';
							Circle_X <= (BLANK_H + RES_H/2);
							Points_1 <= Points_1 + 1;
						END IF;
					END IF;
					IF(Circle_Y<(BLANK_V + 12)) THEN
						Circle_D(0) <= '1';
						Circle_Y <=(BLANK_V + 12);
					END IF;
					IF(Circle_Y>(BLANK_V + RES_V - 12)) THEN
						Circle_D(0) <= '0';
						Circle_Y <=(BLANK_V + RES_V - 12);
					END IF;
				END IF;
			ELSIF(S(4)='1') THEN
				Square_X1 <= BLANK_H;
				Square_Y1 <=(BLANK_V + RES_V/2 - 50);
				
				Square_X2 <= (BLANK_H + RES_H - 15);
				Square_Y2 <= (BLANK_V + RES_V/2 - 50);
				
				Circle_X <= (BLANK_H + RES_H/2);
				Circle_Y <= (BLANK_V + RES_V/2);
				
				Points_1 <= "0000";
				Points_2 <= "0000";
			END IF;
			IF(S(0)='1')THEN
				 IF(KEYS(3)='0' and Square_Y1 > (BLANK_V))THEN
					Square_Y1<=Square_Y1-10;
				 ELSIF(Square_Y1 < 42) THEN
					Square_Y1 <= 42;
				 END IF;
				 IF(KEYS(2)='0' and Square_Y1 < (BLANK_V + RES_V - 100))THEN
					Square_Y1<=Square_Y1+10;
				 ELSIF(Square_Y1 > (BLANK_V + RES_V - 100)) THEN
					Square_Y1 <= (BLANK_V + RES_V - 100);
				 END IF;
			ELSE
				Square_Y1<=Circle_Y-50;
			END IF;
	
			IF(S(1)='1')THEN
				 IF(KEYS(1)='0' and Square_Y2 > (BLANK_V))THEN
					Square_Y2<=Square_Y2-10;
				 ELSIF(Square_Y2 < (BLANK_V)) THEN
					Square_Y2 <= (BLANK_V);
				 END IF;
				 IF(KEYS(0)='0' and Square_Y2 < (BLANK_V + RES_V - 100))THEN
					Square_Y2<=Square_Y2+10;
				 ELSIF(Square_Y2 > (BLANK_V + RES_V - 100)) THEN
					Square_Y2 <= (BLANK_V + RES_V - 100);
				 END IF;
			ELSE
				Square_Y2<=Circle_Y-50;
			END IF;
			IF(S(5)='1') THEN
				Square_Y1 <= BLANK_V + (((RES_V)/256) * to_integer(unsigned(P1_Pos)));
				Square_Y2 <= BLANK_V + (((RES_V)/256) * to_integer(unsigned(P2_Pos)));
			END IF;
		END IF;
	END PROCESS;
END MAIN;