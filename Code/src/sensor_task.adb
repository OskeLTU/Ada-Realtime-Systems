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



      loop
         delay until Next_Release;
         -- Les begge sensorene
         Distance_Front_1 := Sensor1.Read;
         delay until Clock + Milliseconds(30);
         Distance_Front_2  := Sensor2.Read;

         -- Lagre i shared buffer
         Shared_Data.Sensor_Buffer.Set_Distances(Dist_Right => Distance_Front_1, Dist_Left => Distance_Front_2);

         -- Vent til neste periode
         Next_Release := Next_Release + Period;
      end loop;
   end Sensor_Controller;

end Sensor_Task;

