-- VGA Sync&Output

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

ENTITY SYNC IS

generic (
	--DEFAULT---1280x1024 @ 60 Hz pixel clock 108 MHz
	FRONT_PORCH_H : INTEGER := 48;
	SYNC_PULSE_H : INTEGER := 112;
	BACK_PORCH_H : INTEGER := 248;
	RES_H : INTEGER := 1280;
	HSYNC_ACTIVE_VALUE : STD_LOGIC := '1';
	FRONT_PORCH_V : INTEGER := 1;
	SYNC_PULSE_V : INTEGER := 3;
	BACK_PORCH_V : INTEGER := 38;
	RES_V : INTEGER := 1024;
	VSYNC_ACTIVE_VALUE : STD_LOGIC := '0'
);

PORT(
CLK, DRAW: IN STD_LOGIC;
HSYNC, VSYNC, DONE: OUT STD_LOGIC;
R: OUT STD_LOGIC_VECTOR(3 downto 0);
G: OUT STD_LOGIC_VECTOR(3 downto 0);
B: OUT STD_LOGIC_VECTOR(3 downto 0);
S: IN STD_LOGIC_VECTOR(9 downto 6);
HPOS_OUT: OUT UNSIGNED (11 downto 0);
VPOS_OUT: OUT UNSIGNED (11 downto 0)
);
END SYNC;


ARCHITECTURE MAIN OF SYNC IS

CONSTANT BLANK_H: INTEGER := (FRONT_PORCH_H + SYNC_PULSE_H + BACK_PORCH_H);
CONSTANT BLANK_V: INTEGER := (FRONT_PORCH_V + SYNC_PULSE_V + BACK_PORCH_V);
SIGNAL HPOS: INTEGER RANGE 0 TO ((FRONT_PORCH_H + SYNC_PULSE_H + BACK_PORCH_H) + RES_H):=0;
SIGNAL VPOS: INTEGER RANGE 0 TO ((FRONT_PORCH_V + SYNC_PULSE_V + BACK_PORCH_V) + RES_V):=0;

BEGIN

 PROCESS(CLK)
 BEGIN
IF(CLK'EVENT AND CLK='1')THEN
	HPOS_OUT <= to_unsigned(HPOS, 12);
	VPOS_OUT <= to_unsigned(VPOS, 12);
		IF (DRAW='0')THEN --Buttons to change background color
			R(3) <= S(9);
			R(2) <= S(8);
			R(1) <= '0';
			R(0) <= '0';
		   G(3) <= S(7);
			G(2) <= S(6);
			G(1) <= '0';
			G(0) <= '0';
			B(3) <= '0';
			B(2) <= '0';
			B(1) <= '0';
			B(0) <= '0';
		ELSE
			R<=(others=>'1');
			G<=(others=>'1');
			B<=(others=>'1');
		END IF;
		IF(VPOS = (BLANK_V+2) or VPOS = (BLANK_V + RES_V - 1) or HPOS = (BLANK_H + 1) or HPOS = (BLANK_H + RES_H - 1)) THEN
			R<=(others=>'1');
			G<=(others=>'1');
			B<=(others=>'1');
		END IF;
		IF(HPOS<(BLANK_H  + RES_H))THEN
		DONE <= '0';
		HPOS<=HPOS+1;
		ELSE
		HPOS<=0;
		  IF(VPOS<(BLANK_V + RES_V))THEN
			  VPOS<=VPOS+1;
			  ELSE
			  DONE <= '1';
			  VPOS<=0; 
			END IF;
		END IF;
   IF((HPOS>0 AND HPOS<BLANK_H) OR (VPOS>0 AND VPOS<BLANK_V))THEN
	R<=(others=>'0');
	G<=(others=>'0');
	B<=(others=>'0');
	END IF;
   IF(HPOS>FRONT_PORCH_H AND HPOS<(FRONT_PORCH_H + SYNC_PULSE_H))THEN----HSYNC
	   HSYNC<= HSYNC_ACTIVE_VALUE;
	ELSE
	   HSYNC<= NOT HSYNC_ACTIVE_VALUE;
	END IF;
   IF(VPOS>(FRONT_PORCH_V - 1) AND VPOS<(FRONT_PORCH_V + SYNC_PULSE_V))THEN----------vsync
	   VSYNC<= VSYNC_ACTIVE_VALUE;
	ELSE
	   VSYNC<= NOT VSYNC_ACTIVE_VALUE;
	END IF;
 END IF;
 END PROCESS;
 END MAIN;
