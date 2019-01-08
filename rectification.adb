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
    Ethanol_Biol_Temp : Float := 78.9;
	Container_State : Float := 0.0;
	Next_Time : Time := Clock + 0.1;
	The_End : Boolean := False;

    SED1_Valve : Boolean := False; -- False mean closed
    SED1 : Float := 0.0;
    SED2_Valve : Boolean := False;
    SED2 : Float := 0.0;

	procedure CLS is
	begin
		Put(ASCII.ESC & "[2J");
	end CLS;

	task Regulate_Temp;
	task body Regulate_Temp  is

		procedure Increase_Heat is
		begin
		Heater := Float'Min(Heater + 0.3, 200.0);
		end Increase_Heat;

		procedure Decrease_Heat is
		begin
		Heater := Float'Max(Heater - 0.15, 75.0);
		end Decrease_Heat;

	begin
	    Main_Loop : loop

			delay 0.1;
			if Mash_Temperature >= Ethanol_Biol_Temp then
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
				return Float'Min(Mash_Heat+(Heater_Heat-Mash_Heat)/10.0 ,200.0);
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
    		delay 0.4;
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

	task ProductionCalculator;
	task body ProductionCalculator is
    Efficiency : Float := 0.8;
	Vaporated_Amount : Float := 0.1;
    SED1Eff : Float := 0.80;
    SED2Eff : Float := 0.95;
    Production : Float := 0.0;
    Waste : Float := 0.0;
	begin
        loop
            if Mash_Temperature >= Ethanol_Biol_Temp then -- zmienić vaporated zalezne od temperatury
                delay 0.5;
                Production := Vaporated_Amount * Efficiency;
                Waste := Vaporated_Amount - Production;
                SED1 := SED1 + Waste * SED1Eff;
                Waste := Waste - Waste * SED1Eff;
                SED2 := SED2 + Waste * SED2Eff;
                Waste := Waste - Waste * SED2Eff;
                Container_State := Container_State + Production + Waste;
                Mash_Amount := Mash_Amount - Vaporated_Amount;
            end if;
            exit when The_End;
        end loop;
	end ProductionCalculator;

    task ValvesSensor;
    task body ValvesSensor is
        SEDCapacity : Float := 0.5;
        ValveEff : Float := 0.01;
    begin
        loop
            delay 1.0;
            if SED1 >= SEDCapacity then
                SED1_Valve := True;
                while SED1 >= ValveEff loop
                    delay 0.1;
                    Mash_Amount := Mash_Amount + ValveEff;
                    SED1 := SED1 - ValveEff;
                end loop;
                SED1_Valve := False;            
            end if;

            if SED2 >= SEDCapacity then
                SED2_Valve := True;
                while SED2 >= ValveEff loop
                    delay 0.1;
                    Mash_Amount := Mash_Amount + ValveEff;
                    SED2 := SED2 - ValveEff;
                end loop;
                SED2_Valve := False;
            end if;
            exit when The_End;
        end loop;
    end ValvesSensor;


begin
	Main_Loop: loop
        CLS;
        New_Line;
        Put("Heater temp:"); Put("    "); Put("Mash temp:");
    	New_Line;
    	Put(Heater+50.0,3,2,0); Put(" C"); -- na pale +50 stopni !! do zmiany
        Put("       ");
        Put(Mash_Temperature,3,2,0); Put(" C");
    	New_Line; New_Line;

    	Put("Mash amount:"); Put("    "); Put("Spirit produced:");
        New_Line;
        Put(Mash_Amount,3,2,0); Put(" L");
        Put("       ");
        Put(Container_State,3,2,0); Put(" L");
        New_Line; New_Line;

        Put("Sedimentation Tank 1: "); Put(SED1,3,2,0); Put(" L    Valve: ");
        if SED1_Valve then Put("OPEN"); else Put("CLOSED"); end if;
        New_Line;
        Put("Sedimentation Tank 2: "); Put(SED2,3,2,0); Put(" L    Valve: ");
        if SED2_Valve then Put("OPEN"); else Put("CLOSED"); end if;
        New_Line;
        delay 0.01;
    	exit when Button_Clicked in 'q'|'Q';
	end loop Main_Loop;
	The_End := True;
end rectification;
