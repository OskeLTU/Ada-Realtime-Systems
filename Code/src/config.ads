with Ada.Real_Time;  use Ada.Real_Time;
with MicroBit.Types; use MicroBit.Types;
with System;

package Config is

   -- WCRT_Sensor = 117ms
   -- WCRT_Logic = 1ms
   -- WCRT_Total = 118ms

   -- Vi setter periode til 120ms for å ha 2ms margin
   Sensor_Period : constant Time_Span := Milliseconds(120);
   Logic_Period  : constant Time_Span := Milliseconds(120);

   -- Høyere verdi = høyere prioritet
   Priority_Sensor : constant System.Priority := System.Priority'Last - 1;
   Priority_Logic  : constant System.Priority := System.Priority'Last - 2;
   Priority_Buffer : constant System.Priority := System.Priority'Last;


   -- Terskelverdier for hindringer (cm)
   Obstacle_Threshold_Front : constant Distance_cm := Distance_cm(10.0);
   Obstacle_Threshold_Back  : constant Distance_cm := Distance_cm(10.0);


   -- Motor hastighet (0-4095)
   Motor_Speed_Forward : constant := 4095;

   -- Servo initial posisjon (grader)
   Servo_Initial_Position : constant := 90;


   Enable_Sensor_Debug : constant Boolean := True;
   Enable_Logic_Debug  : constant Boolean := True;
   Enable_Timing_Debug : constant Boolean := False;

end Config;
