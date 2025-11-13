
with Ada.Real_Time;        use Ada.Real_Time;
with MicroBit.Types;       use MicroBit.Types;
with MicroBit.MotorDriver; use MicroBit.MotorDriver;
with DFR0548;
with MicroBit.Console;     use MicroBit.Console;
use MicroBit;
with Shared_Data;
with Config;


package body Logic_Task is

   type Robot_State is (
      CRUISING,
      BACKING_UP,
      PAUSING,
      TURNING_RIGHT,
      TURNING_LEFT,
      STOPPING
   );


   Backup_Duration   : constant Time_Span := Milliseconds(1000);
   Turn_90_Duration  : constant Time_Span := Milliseconds(1100);
   Short_Pause       : constant Time_Span := Milliseconds(200);
   Very_Short_Pause  : constant Time_Span := Milliseconds(100);

   task body Logic_Controller is
      Period        : constant Time_Span := Config.Logic_Period;
      Next_Release  : Time := Clock;

      Distance_Right : Distance_cm;
      Distance_Left  : Distance_cm;

      T_Start : Time;
      T_End   : Time;
      Elapsed : Time_Span;

      Threshold_Min : constant Distance_cm := Distance_cm(3.0);
      Threshold_Max : constant Distance_cm := Distance_cm(200.0);
      Obstacle_Distance : constant Distance_cm := Distance_cm(20.0);


      Current_State      : Robot_State := CRUISING;
      Action_End_Time    : Time := Clock;
      Next_State_After_Action : Robot_State := CRUISING;

      Previous_Right_Blocked : Boolean := False;
      Previous_Left_Blocked  : Boolean := False;


   begin
      loop
         T_Start := Clock;

         Shared_Data.Sensor_Buffer.Get_Distances(Distance_Right, Distance_Left);

         declare
            Right_Valid : constant Boolean :=
               Distance_Right >= Threshold_Min and Distance_Right <= Threshold_Max;
            Left_Valid : constant Boolean :=
               Distance_Left >= Threshold_Min and Distance_Left <= Threshold_Max;

            Right_Blocked : constant Boolean :=
               Right_Valid and Distance_Right < Obstacle_Distance;
            Left_Blocked : constant Boolean :=
               Left_Valid and Distance_Left < Obstacle_Distance;
         begin

            case Current_State is

               when CRUISING =>

                  if Right_Blocked and Left_Blocked then
                     MotorDriver.Drive(Backward, (4095, 4095, 4095, 4095));
                     Action_End_Time := Clock + Backup_Duration;
                     Current_State := BACKING_UP;

                  elsif Right_Blocked and not Left_Blocked then
                     MotorDriver.Drive(Stop);
                     Action_End_Time := Clock + Very_Short_Pause;
                     Current_State := STOPPING;
                     Next_State_After_Action := TURNING_LEFT;

                  elsif Left_Blocked and not Right_Blocked then
                     MotorDriver.Drive(Stop);
                     Action_End_Time := Clock + Very_Short_Pause;
                     Current_State := STOPPING;
                     Next_State_After_Action := TURNING_RIGHT;

                  else
                     MotorDriver.Drive(Forward, (4095, 4095, 4095, 4095));
                  end if;

               when BACKING_UP =>
                  if Clock >= Action_End_Time then
                     MotorDriver.Drive(Stop);
                     Action_End_Time := Clock + Short_Pause;
                     Current_State := PAUSING;
                     Next_State_After_Action := TURNING_RIGHT;
                  end if;

               when PAUSING =>
                  if Clock >= Action_End_Time then

                     if Next_State_After_Action = TURNING_RIGHT then
                        MotorDriver.Drive(Rotating_Right, (4095, 4095, 4095, 4095));
                        Action_End_Time := Clock + Turn_90_Duration;
                        Current_State := TURNING_RIGHT;

                     elsif Next_State_After_Action = TURNING_LEFT then
                        MotorDriver.Drive(Rotating_Left, (4095, 4095, 4095, 4095));
                        Action_End_Time := Clock + Turn_90_Duration;
                        Current_State := TURNING_LEFT;

                     else
                        MotorDriver.Drive(Forward, (4095, 4095, 4095, 4095));
                        Current_State := CRUISING;
                     end if;
                  end if;

               when TURNING_RIGHT =>
                  if Clock >= Action_End_Time then
                     MotorDriver.Drive(Forward, (4095, 4095, 4095, 4095));
                     Current_State := CRUISING;
                  end if;

               when TURNING_LEFT =>
                  if Clock >= Action_End_Time then
                     MotorDriver.Drive(Forward, (4095, 4095, 4095, 4095));
                     Current_State := CRUISING;
                  end if;

               when STOPPING =>
                  if Clock >= Action_End_Time then

                     if Next_State_After_Action = TURNING_LEFT then
                        MotorDriver.Drive(Backward, (4095, 4095, 4095, 4095));
                        Action_End_Time := Clock + Very_Short_Pause;
                        Current_State := PAUSING;


                     elsif Next_State_After_Action = TURNING_RIGHT then
                        MotorDriver.Drive(Backward, (4095, 4095, 4095, 4095));
                        Action_End_Time := Clock + Very_Short_Pause;
                        Current_State := PAUSING;


                     else
                        MotorDriver.Drive(Forward, (4095, 4095, 4095, 4095));
                        Current_State := CRUISING;
                     end if;
                  end if;

            end case;

         end;

         T_End := Clock;
         Elapsed := T_End - T_Start;


         Next_Release := Next_Release + Period;
         delay until Next_Release;

      end loop;
   end Logic_Controller;

end Logic_Task;












































