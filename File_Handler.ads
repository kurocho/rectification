package File_Handler is
procedure Create_File_With_Current_State(Heater, Mash_Temperature,
                                            Room_Temperature, Mash_Amount,
                                            Starting_Mash_Amount, Potential_Ethanol_Percentage,
                                            Potential_Ethanol_Amount, Container_State,
                                            SED1, SED2,
                                            Time_Passed: Float);
procedure Read_State_From_File(Heater, Mash_Temperature,
								Room_Temperature, Mash_Amount,
								Starting_Mash_Amount, Potential_Ethanol_Percentage,
								Potential_Ethanol_Amount, Container_State,
								SED1, SED2,
								Time_Passed: out Float);
end File_Handler;
