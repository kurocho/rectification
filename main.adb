with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Float_Text_IO;
use Ada.Float_Text_IO;

with Ada.Calendar;
use Ada.Calendar;

with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Float_Text_IO;
use Ada.Float_Text_IO;

with Ada.Calendar;
use Ada.Calendar;
with Ada.Numerics.Float_Random;

with Ada.Strings;
use Ada.Strings;
with Ada.Strings.Fixed;
use Ada.Strings.Fixed;

with Ada.Exceptions;
use Ada.Exceptions;



procedure Main is
    Button_Clicked : Character;
	Heater : Float := 19.0 with Atomic;
	Mash_Temperature : Float := 19.0 with Atomic;
	Room_Temperature : Float := 19.0;
	Mash_Amount : Float := 10.0 with Atomic;
	Starting_Mash_Amount : Float := Mash_Amount with Atomic;
	Potential_Ethanol_Percentage : Float := 8.00 with Atomic;
	Potential_Ethanol_Amount : Float := (Potential_Ethanol_Percentage/100.0)*Starting_Mash_Amount with Atomic;
	Ethanol_Biol_Temp : Float := 78.9 with Atomic;
	Container_State : Float := 0.0 with Atomic;
	Next_Time : Time := Clock + 0.1 with Atomic;
	The_End : Boolean := False with Atomic;

	SED1_Valve : Boolean := False with Atomic; -- False mean closed
	SED1 : Float := 0.0 with Atomic;
	SED2_Valve : Boolean := False with Atomic;
	SED2 : Float := 0.0 with Atomic;
	Time_Passed : Float := 0.0 with Atomic;

	procedure Initialize_Data is
	begin
		Starting_Mash_Amount := Mash_Amount ;
		Potential_Ethanol_Amount:= (Potential_Ethanol_Percentage/100.0)*Starting_Mash_Amount ;
	end Initialize_Data;


	type TextAttributes is (Clear, Bright, Underlined, Negative, Flashing, Gray, Red, Green);

	protected Screen  is
	  procedure Print_XY(X,Y: Positive; S: String; Attrib : TextAttributes := Clear);
	  procedure Print_Float_XY(X, Y: Positive;
	                          Num: Float;
	                          Pre: Natural := 3;
	                          Aft: Natural := 2;
	                          Exp: Natural := 0;
	                          Attrib : TextAttributes := Clear);
	  procedure CLS;
	  procedure Sim_Background;
	  procedure Menu_Background;
	  procedure PrintData;
	end Screen;

	protected body Screen is
	  -- implementacja dla Linuxa i macOSX
	  function Attrib_Fun(Attrib : TextAttributes) return String is
	    (case Attrib is
	     when Bright => "1m", when Underlined => "4m", when Negative => "7m",
	     when Flashing => "5m", when Gray => "37m", when Clear => "0m", when Red => "31m", when Green => "32m");

	  function Esc_XY(X,Y : Positive) return String is
	    ( (ASCII.ESC & "[" & Trim(Y'Img,Both) & ";" & Trim(X'Img,Both) & "H") );

	  procedure Print_XY(X,Y: Positive; S: String; Attrib : TextAttributes := Clear) is
	    Przed : String := ASCII.ESC & "[" & Attrib_Fun(Attrib);
	  begin
	    Put( Przed);
	    Put( Esc_XY(X,Y) & S);
	    Put( ASCII.ESC & "[0m");
	  end Print_XY;

	  procedure Print_Float_XY(X, Y: Positive;
	                          Num: Float;
	                          Pre: Natural := 3;
	                          Aft: Natural := 2;
	                          Exp: Natural := 0;
	                          Attrib : TextAttributes := Clear) is

	    Przed_Str : String := ASCII.ESC & "[" & Attrib_Fun(Attrib);
	  begin
	    Put( Przed_Str);
	    Put( Esc_XY(X, Y) );
	    Put( Num, Pre, Aft, Exp);
	    Put( ASCII.ESC & "[0m");
	  end Print_Float_XY;

	  procedure CLS is
	  begin
	    Put(ASCII.ESC & "[2J");
	  end CLS;

	  procedure Menu_Background is
	  begin
	    Screen.CLS;
	    Screen.Print_XY(1,1,"############################ Menu ############################",Gray);
	    for I in Integer range 2..30 loop
	        Screen.Print_XY(1,I,"#",Gray);
	        Screen.Print_XY(62,I,"#",Gray);
	    end loop;
	    Screen.Print_XY(3,3,"Click 'I/i' to enter your own data - mash amount in litres",Gray);
	    Screen.Print_XY(3,4,"and expected alcolhol ",Gray);
	    Screen.Print_XY(3,6,"Click 'L/l' to load from a file ",Gray);
	    Screen.Print_XY(3,7,"Click 'Q/q' to exit",Gray);
	    Screen.Print_XY(3,15,"(Any other input will result in )",Gray);
	    Screen.Print_XY(3,16,"(running the default simmulation)",Gray);

	    Screen.Print_XY(1,31,"##############################################################",Gray);
	  end Menu_Background;

	  procedure Sim_Background is
	  begin
	    Screen.Print_XY(1,1,"#################### Spirit Rectification ####################",Gray);
	    for I in Integer range 2..30 loop
	        Screen.Print_XY(1,I,"#",Gray);
	        Screen.Print_XY(62,I,"#",Gray);
	    end loop;
	    Screen.Print_XY(44,2,"Time passed:",Gray);
	    Screen.Print_XY(3,3,"Heater temp:",Gray);
	    Screen.Print_XY(25,3,"Mash temp:",Gray);
	    Screen.Print_XY(3,6,"Mash amount:",Gray);
	    Screen.Print_XY(25,6,"Spirit produced:",Gray);
	    Screen.Print_XY(3,9,"Sedimentation Tank 1:",Gray);
	    Screen.Print_XY(35,9,"Valve:",Gray);
	    Screen.Print_XY(3,10,"Sedimentation Tank 2:",Gray);
	    Screen.Print_XY(35,10,"Valve:",Gray);
	    Screen.Print_XY(32,30,"Click 'Q/q' to end simulation",Flashing);
	    Screen.Print_XY(1,31,"##############################################################",Gray);
	  end Sim_Background;

	  procedure PrintData is
	  begin -- PrintData
          Screen.Print_Float_XY(56,2,Time_Passed,3,0,0,Gray);
	      Screen.Print_Float_XY(15,3,Heater,3,2,0,Green);
	  if Mash_Temperature > 81.0 then Screen.Print_Float_XY(35,3,Mash_Temperature,3,2,0,Red); else Screen.Print_Float_XY(35,3,Mash_Temperature,3,2,0,Green); end if;

	      Screen.Print_Float_XY(16,6,Mash_Amount,3,2,0,Green);
	      Screen.Print_Float_XY(41,6,Container_State,3,2,0,Green);
	      Screen.Print_Float_XY(25,9,SED1,3,2,0,Green);
	  if SED1_Valve then Screen.Print_XY(42,9,"Open",Bright); else Screen.Print_XY(42,9,"Closed",Red); end if;
	      Screen.Print_Float_XY(25,10,SED2,3,2,0,Green);
	  if SED2_Valve then Screen.Print_XY(42,10,"Open",Bright); else Screen.Print_XY(42,10,"Closed",Red); end if;
	  end PrintData;

	end Screen;


	procedure rectification is
		task Count_Time;
		task body Count_Time is
		begin
			while The_End = False loop
			delay 0.2;
			Time_Passed :=Time_Passed+0.2;
			end loop;
		end Count_Time;

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
			while The_End = False loop
				delay 0.1;
				if Mash_Temperature >= Ethanol_Biol_Temp then
					Decrease_Heat;
				else
					Increase_Heat;
				end if;
			end loop;
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
			while The_End = False loop
				--delay until Next_Time;
				delay 0.4;
				--Put_Line("mash loop");
				Update_Mash_Update;
			end loop;
		end Current_Temperature;


		task ProductionCalculator;
		task body ProductionCalculator is
		Efficiency : Float := 0.8;
		Vaporated_Amount : Float := 0.05;
		SED1Eff : Float := 0.80;
		SED2Eff : Float := 0.95;
		Production : Float := 0.0;
		Waste : Float := 0.0;
		begin
		    while The_End = False loop
		    	delay 0.5;
		        if Mash_Temperature >= Ethanol_Biol_Temp then -- zmienić vaporated zalezne od temperatury
		            if Container_State <= Potential_Ethanol_Amount then
				        Production := Vaporated_Amount * Efficiency;
				        Waste := Vaporated_Amount - Production;
				        SED1 := SED1 + Waste * SED1Eff;
				        Waste := Waste - Waste * SED1Eff;
				        SED2 := SED2 + Waste * SED2Eff;
				        Waste := Waste - Waste * SED2Eff;
				        Container_State := Container_State + Production + Waste;
				        Mash_Amount := Mash_Amount - Vaporated_Amount;
				    else
				    	null;
				    end if;
		        end if;
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


		task Controls;
		task body Controls is
		begin
			while The_End = False loop
			delay 0.1;
                Get_Immediate(Button_Clicked);
                if Button_Clicked  in 'q'|'Q' then
                    The_End := True;
                end if;
			end loop;
		end Controls;

	begin
		--Get_User_Data;
		while The_End = False loop
		    Screen.Sim_Background;
		    Screen.PrintData;
		    Screen.Print_XY(1,32,"",Clear);
		    delay 0.1;
		end loop;
		The_End := True;
		Screen.Print_XY(1,500,"",Clear);
		Screen.CLS;
	end rectification;

    procedure Get_User_Data is
        begin
        Screen.Print_XY(1,1,"",Clear);
        Screen.ClS;
        Put_Line("");
        Put_Line("Enter Starting Mash Amount(litres):  ");
        Get(Mash_Amount);
        Put_Line("Enter potential alcohol percentage (in %): ");
        Get(Potential_Ethanol_Percentage);
        Initialize_Data;
    end Get_User_Data;

    procedure FirstScreen is
        begin
            Screen.Menu_Background;
    		get_Immediate(Button_Clicked);
    		if Button_Clicked in 'I'|'i' then
    			Get_User_Data;
    		end if;
    end FirstScreen;



	begin
        FirstScreen;
        Screen.CLS;
		rectification;
        exception when Data_Error =>
            Screen.CLS;
            Screen.Print_XY(1,1,"You've inserted incorrect data!",Red);
            Screen.Print_XY(1,2,"Click anything to end",Green);
            get_Immediate(Button_Clicked);
            The_End := False;
	end Main;
