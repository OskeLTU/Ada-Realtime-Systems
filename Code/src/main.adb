with MicroBit.Console; use MicroBit.Console;
with Sensor_Task;
with Logic_Task;
with Ada.Real_Time; use Ada.Real_Time;


procedure Main is
   Next_Time : Time;
begin

   Next_Time := Clock;

   loop
      Next_Time := Next_Time + Seconds(10);
      delay until Next_Time;
   end loop;

end Main;
