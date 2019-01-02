with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Float_Text_IO;
use Ada.Float_Text_IO;

with Ada.Calendar;
use Ada.Calendar;



procedure rectification is

	Heater : Float := 19.0;
	Mash_Temperature : Float := 19.0;
	Room_Temperature : Float := 19.0;
	Next_Time : Time := Clock + 0.1;
	The_End : Boolean := False;

	procedure CLS is
	begin
		Put(ASCII.ESC & "[2J");
	end CLS;

	task Regulate_Temp;
	task body Regulate_Temp  is

		procedure Increase_Heat is
		begin
		Heater := Float'Min(Heater + 0.2, 800.0);
		end Increase_Heat;

		procedure Decrease_Heat is
		begin
		Heater := Float'Max(Heater - 0.5, 80.0);
		end Decrease_Heat;

	begin
	    Main_Loop : loop
			--delay until Next_Time;
			delay 0.2;
			if Mash_Temperature >= 84.0 then
				Decrease_Heat;
			else
				Increase_Heat;
			end if;
			--Put_Line("Heater loop");
			--Put(Heater,3,2,0);
			exit when The_End; -- exit the heater loop
		end loop Main_Loop;
	end Regulate_Temp;

	task Current_Temperature;
	task body Current_Temperature is

		function Calculate_Mash_Temperature (Heater_Heat, Mash_Heat :Float) return Float is
		begin
			if Heater_Heat >= Mash_Heat + 18.0 then -- 18 jako strata ciepla
				return Float'Min(Mash_Heat+(Heater_Heat-Mash_Heat)/10.0 ,100.0);
			else
				return Float'Max(Mash_Heat-(Mash_Heat-Heater_Heat)/10.0 ,Room_Temperature);
			end if;
		end Calculate_Mash_Temperature;

		procedure Update_Mash_Update is
		begin
    		Mash_Temperature := Calculate_Mash_Temperature(Heater, Mash_Temperature);--get actual data
		end Update_Mash_Update;

	begin
    	Main_Loop: loop
    		--delay until Next_Time;
    		delay 0.5;
    		--Put_Line("mash loop");

    		Update_Mash_Update;
    		exit when The_End;
    	end loop Main_Loop;
	end Current_Temperature;

	Button_Clicked : Character;

begin
	Main_Loop: loop
        CLS;
        New_Line;
    	Put_Line("Heater temp:");
    	Put(Heater,3,2,0);
    	New_Line;
    	Put_Line("Mash temp:");
    	Put(Mash_Temperature,3,2,0);
        New_Line;
        delay 0.7;
        CLS;

    	--Get_Immediate(Button_Clicked);
    	exit when Button_Clicked in 'q'|'Q';
	end loop Main_Loop;
	The_End := True;
end rectification;
