with Text_IO;
procedure Demo is

Line : String(1.. 180);
Last : Integer;

The_Float : Float;

begin
  Text_IO.Get_Line(Item => Line, Last => Last);
  The_Float := Float'value(Line(1 .. Last));

  Text_IO.Put_Line("You gave me " & Float'image(The_Float));
end Demo;
