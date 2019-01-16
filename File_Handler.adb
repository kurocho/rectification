with Ada.Text_IO;  use Ada.Text_IO;
with Ada.Command_Line; use Ada.Command_Line;

package body File_Handler is
    procedure Create_File_With_Current_State (Heater, Mash_Temperature,
    											Room_Temperature, Mash_Amount,
    											Starting_Mash_Amount, Potential_Ethanol_Percentage,
    											Potential_Ethanol_Amount, Container_State,
    											SED1, SED2,
    											Time_Passed: Float) is
    File_Name : constant String := "state.dat";

    F : File_Type;
    begin
       begin
    	  Open (F, Mode => Out_File, Name => File_Name);
       exception
    	  when Name_Error => Create (F, Mode => Out_File, Name => File_Name);
       end;

       Put_Line(F,Heater'Img);
       Put_Line(F,Mash_Temperature'Img);
       Put_Line(F,Room_Temperature'Img);
       Put_Line(F,Mash_Amount'Img);
       Put_Line(F,Starting_Mash_Amount'Img);
       Put_Line(F,Potential_Ethanol_Percentage'Img);
       Put_Line(F,Potential_Ethanol_Amount'Img);
       Put_Line(F,Container_State'Img);
       Put_Line(F,SED1'Img);
       Put_Line(F,SED2'Img);
       Put_Line(F,Time_Passed'Img);
       Close (F);
       Put_Line("File saved to state.dat");
    end Create_File_With_Current_State;


    procedure Read_State_From_File(Heater, Mash_Temperature,
    								Room_Temperature, Mash_Amount,
    								Starting_Mash_Amount, Potential_Ethanol_Percentage,
    								Potential_Ethanol_Amount, Container_State,
    								SED1, SED2,
    								Time_Passed: out Float) is
        File_Name : constant String := "state.dat";
        F : File_Type;
        begin
        	Open (File => F, Mode => In_File, Name => File_Name);
        	Heater := Float'value(Get_Line(F));
        	Mash_Temperature := Float'value(Get_Line(F));
        	Room_Temperature := Float'value(Get_Line(F));
        	Mash_Amount := Float'value(Get_Line(F));
        	Starting_Mash_Amount := Float'value(Get_Line(F));
        	Potential_Ethanol_Percentage := Float'value(Get_Line(F));
        	Potential_Ethanol_Amount := Float'value(Get_Line(F));
        	Container_State := Float'value(Get_Line(F));
        	SED1 := Float'value(Get_Line(F));
        	SED2 := Float'value(Get_Line(F));
        	Time_Passed := Float'value(Get_Line(F));

        	close(F);
    end Read_state_From_File;
end File_Handler;
