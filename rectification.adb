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
	Mash_Amount : Float := 100.0;
	Container_State : Float := 0.0;
	Next_Time : Time := Clock + 0.1;
	Efficiency : Float := 0.6;
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
		
			delay 0.2;
			if Mash_Temperature >= 85.0 then
				Decrease_Heat;
			else
				Increase_Heat;
			end if;
			
			exit when The_End; 
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
	
	task Controls;
	task body Controls is
	begin
	Get_Immediate(Button_Clicked);
	end Controls;
	
	task Valve;
	task body Valve is
	Vaporated_Amount : Float := 0.01;
	begin
		if Mash_Temperature >= 84.00 then
			delay 0.5;
			Container_State := Container_State + Efficiency * Vaporated_Amount;
			Mash_Amount := Mash_Amount - Vaporated_Amount;
		end if;
	end Valve;

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
    	Put("Bottle state");
        New_Line;
        Put(Container_State,3,2,0);
        delay 0.7;
        

    	
    	exit when Button_Clicked in 'q'|'Q';
	end loop Main_Loop;
	The_End := True;
end rectification;
