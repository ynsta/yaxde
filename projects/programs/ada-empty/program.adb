package body Program is

   --  Called Once
   procedure Program_Setup is
   begin
      --  put your program setup code here
      null;
   end Program_Setup;

   --  Called in a loop while True, reset when False
   function Program_Loop return Integer is
   begin
      --  put your program loop code
      return 1; --  return 0 to reset
   end Program_Loop;

end Program;
