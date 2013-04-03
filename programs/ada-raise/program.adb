package body Program is

   --  Called Once
   procedure Program_Setup is
   begin
      null;
   end Program_Setup;


   type Small is range 0 .. 7;

   A : Small := 5;
   B : Small := 0;
   C : Small;

   --  Called in a loop while True, reset when False
   function Program_Loop return Integer is
   begin

      B := B + 1;

      C := A + B;

      return 1;
   end Program_Loop;

end Program;
