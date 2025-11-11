with MicroBit.Console; use MicroBit.Console;
with Sensor_Task;
with Logic_Task;
with Ada.Real_Time; use Ada.Real_Time;


procedure Main is
   Next_Time : Time;
begin
   Put_Line("=================================");
   Put_Line("FPS Car Control System Starting");
   Put_Line("=================================");
   Put_Line("Sensor Task Priority: High");
   Put_Line("Logic Task Priority: Normal");
   Put_Line("Period: 120ms");
   Put_Line("=================================");


   Next_Time := Clock;

   loop
      Next_Time := Next_Time + Seconds(10);
      delay until Next_Time;
   end loop;

end Main;
