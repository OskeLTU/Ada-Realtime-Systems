with Ada.Real_Time; use Ada.Real_Time;
with MicroBit.Ultrasonic;
with MicroBit.Types; use MicroBit.Types;
with MicroBit.Console; use MicroBit.Console;
with Shared_Data;
with Config;
use MicroBit;

package body Sensor_Task is

   package Sensor1 is new Ultrasonic(MB_P16, MB_P15);
   package Sensor2 is new Ultrasonic(MB_P14, MB_P13);

   task body Sensor_Controller is
      Period : constant Time_Span := Config.Sensor_Period; --sykeluss perioden 120ms.
      Next_Release : Time := Clock; --Starter på nåværende tid.


      Distance_Front_1 : Distance_cm;
      Distance_Front_2  : Distance_cm;

   begin

      Next_Release := Next_Release + Period; --Planlegger første aktivering (T0 + periode)
      if Config.Enable_Sensor_Debug then
         Put_Line("Sensor Task: Started");
      end if;


      loop
         delay until Next_Release;
         -- Les begge sensorene
         Distance_Front_1 := Sensor1.Read;
         delay until Clock + Milliseconds(30);
         Distance_Front_2  := Sensor2.Read;

         -- Lagre i shared buffer
         Shared_Data.Sensor_Buffer.Set_Distances(Dist_Right => Distance_Front_1, Dist_Left => Distance_Front_2);

         -- Debug output
         if Config.Enable_Sensor_Debug then
            Put_Line("Sensor: Front_1=" & Distance_cm'Image(Distance_Front_1) &
                     " Front_2=" & Distance_cm'Image(Distance_Front_2));
         end if;

         -- Vent til neste periode
         Next_Release := Next_Release + Period;
      end loop;
   end Sensor_Controller;

end Sensor_Task;

--  <<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

--  with Ada.Real_Time; use Ada.Real_Time;
--  with MicroBit.Types; use MicroBit.Types;
--  with MicroBit.Console; use MicroBit.Console;
--  with Shared_Data;
--  with Config;
--  with Sensors; -- <== ADDED YOUR PACKAGE
--  use MicroBit;

--  package body Sensor_Task is

--     task body Sensor_Controller is
--        Period : constant Time_Span := Config.Sensor_Period;  -- 120ms
--        Next_Release : Time := Clock;
--        Distance_L : Distance_cm;
--        Distance_R : Distance_cm;
--     begin
--        -- Run your sensor setup procedure ONCE
--        Sensors.sensor_control_setup;

--        Next_Release := Next_Release + Period;
--        if Config.Enable_Sensor_Debug then
--           Put_Line("Sensor Task: Started (Using Interrupts)");
--        end if;

--        loop
--           delay until Next_Release;

--           -- 1. Get the values from the *previous* measurement cycle
--           --    (The interrupts updated these values in the background)
--           Distance_R := Sensors.Right_Distance;
--           Distance_L := Sensors.Left_Distance;

--           -- 2. Store these values for the Logic_Task to use
--           Shared_Data.Sensor_Buffer.Set_Distances(Distance_R, Distance_L);

--           -- 3. Trigger the *next* measurement cycle
--           --    (The interrupts will fire again while this task is sleeping)
--           Sensors.Trig_right;
--           Sensors.Trig_left;

--           -- Debug output
--           if Config.Enable_Sensor_Debug then
--              Put_Line("Sensor: R=" & Distance_cm'Image(Distance_R) &
--                       " L=" & Distance_cm'Image(Distance_L));
--           end if;

--           -- Wait for the next period
--           Next_Release := Next_Release + Period;
--        end loop;
--     end Sensor_Controller;

--  end Sensor_Task;
