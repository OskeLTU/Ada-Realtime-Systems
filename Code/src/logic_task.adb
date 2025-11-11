
with Ada.Real_Time;        use Ada.Real_Time;
with MicroBit.Types;       use MicroBit.Types;
with MicroBit.MotorDriver; use MicroBit.MotorDriver;
with DFR0548;
with MicroBit.Console;     use MicroBit.Console;
use MicroBit;
with Shared_Data;
with Config;

package body Logic_Task is

   -- Timing konstanter som Time_Span
   Servo_Settle_Time : constant Time_Span := Milliseconds(400);
   Turn_90_Duration  : constant Time_Span := Milliseconds(1100);
   Turn_180_Duration : constant Time_Span := Milliseconds(1400);
   Backup_Duration   : constant Time_Span := Milliseconds(1000);
   Short_Pause       : constant Time_Span := Milliseconds(200);

   --  task body Logic_Controller is
   --     Period : constant Time_Span := Config.Logic_Period;
   --     Next_Release : Time := Clock;

   --     Distance_Right : Distance_cm;
   --     Distance_Left  : Distance_cm;
   --     Distance_Scan  : Distance_cm;
   --     Dummy : Distance_cm;

   --     Threshold : constant Distance_cm := Distance_cm(15.0);

   --     -- Hjelpevariabel for timing
   --     Action_Complete_Time : Time;

   --  begin
   --     Put_Line("=== INTELLIGENT CAR (Full Real_Time) ===");

   --     -- Senter servo
   --     MotorDriver.Servo(1, 90);
   --     Action_Complete_Time := Clock + Servo_Settle_Time;
   --     delay until Action_Complete_Time;

   --     loop
   --        -- Les sensorer
   --        Shared_Data.Sensor_Buffer.Get_Distances(Distance_Right, Distance_Left);

   --        if Distance_Right < Threshold or Distance_Left < Threshold then
   --           Put_Line("OBSTACLE! Right=" & Distance_cm'Image(Distance_Right));
   --           MotorDriver.Drive(Stop);
   --           Action_Complete_Time := Clock + Short_Pause;
   --           delay until Action_Complete_Time;

   --           -- SKANN VENSTRE
   --           Put_Line("Scanning LEFT...");
   --           MotorDriver.Servo(1, 180);
   --           Action_Complete_Time := Clock + Servo_Settle_Time;
   --           delay until Action_Complete_Time;

   --           Shared_Data.Sensor_Buffer.Get_Distances(Dummy, Distance_Scan);
   --           Put_Line("  Left: " & Distance_cm'Image(Distance_Scan) & " cm");

   --           if Distance_Scan > Threshold then
   --              -- VENSTRE ER ÅPEN
   --              Put_Line("=> Turning LEFT");
   --              MotorDriver.Servo(1, 90);
   --              Action_Complete_Time := Clock + Short_Pause;
   --              delay until Action_Complete_Time;

   --              MotorDriver.Drive(Forward, (0, 0, 4095, 4095)); -- Left turn
   --              Action_Complete_Time := Clock + Turn_90_Duration;
   --              delay until Action_Complete_Time;


   --           else
   --              -- VENSTRE BLOKKERT - SKANN HØYRE
   --              Put_Line("Scanning RIGHT...");
   --              MotorDriver.Servo(1, 0);
   --              Action_Complete_Time := Clock + Servo_Settle_Time;
   --              delay until Action_Complete_Time;

   --              Shared_Data.Sensor_Buffer.Get_Distances(Distance_Scan, Dummy);
   --              Put_Line("  Right: " & Distance_cm'Image(Distance_Scan) & " cm");

   --              if Distance_Scan > Threshold then
   --                 -- HØYRE ER ÅPEN
   --                 Put_Line("=> Turning RIGHT");
   --                 MotorDriver.Servo(1, 90);
   --                 Action_Complete_Time := Clock + Short_Pause;
   --                 delay until Action_Complete_Time;

   --                 MotorDriver.Drive(Forward, (4095, 4095, 0, 0)); --Right turn
   --                 Action_Complete_Time := Clock + Turn_90_Duration;
   --                 delay until Action_Complete_Time;


   --              else
   --                 -- BEGGE BLOKKERT - RYGGE!
   --                 Put_Line("=> BACKING UP (all blocked)");
   --                 MotorDriver.Servo(1, 90);
   --                 Action_Complete_Time := Clock + Short_Pause;
   --                 delay until Action_Complete_Time;

   --                 -- Rygge
   --                 MotorDriver.Drive(Backward, (4095, 4095, 4095, 4095));
   --                 Action_Complete_Time := Clock + Backup_Duration;
   --                 delay until Action_Complete_Time;

   --                 put_line("stopping to turn");
   --                 MotorDriver.Drive(Stop);
   --                 Action_Complete_Time := Clock + Short_Pause;
   --                 delay until Action_Complete_Time;

   --                 -- Snu 180 grader
   --                 --  Put_Line("=> Turning around");
   --                 --  MotorDriver.Drive(Rotating_Right, (4095, 4095, 4095, 4095));
   --                 --  Action_Complete_Time := Clock + Turn_180_Duration;
   --                 --  delay until Action_Complete_Time;

   --              end if;
   --           end if;


   --        else
   --           Put_Line("Clear - Moving forward");
   --           MotorDriver.Drive(Forward, (4095, 4095, 4095, 4095));
   --        end if;

   --        Next_Release := Next_Release + Period;
   --        delay until Next_Release;

   --     end loop;
   --  end Logic_Controller;

task body Logic_Controller is
      Period : constant Time_Span := Config.Logic_Period;
      Next_Release : Time := Clock;

      Distance_Right : Distance_cm;
      Distance_Left  : Distance_cm;

      -- Threshold is 5cm
      Threshold : constant Distance_cm := Distance_cm(5.0);

      -- Hjelpevariabel for timing
      Action_Complete_Time : Time;

   begin
      Put_Line("=== INTELLIGENT CAR (Decisive Logic) ===");

      loop
         -- 1. Les sensorer (Read sensors)
         Shared_Data.Sensor_Buffer.Get_Distances(Distance_Right, Distance_Left);

         -- 2. Definer tilstander (Define states)
         declare
            Right_Blocked : constant Boolean := Distance_Right < Threshold;
            Left_Blocked  : constant Boolean := Distance_Left < Threshold;
         begin
            -- 3. Handle Scenarios

            if Right_Blocked and Left_Blocked then
               -- SCENARIO 1: HEAD-ON OBSTACLE
               Put_Line("Head-on Obstacle! Backing up...");

               -- Action 1: Drive backward
               MotorDriver.Drive(Backward, (4095, 4095, 4095, 4095));
               Action_Complete_Time := Clock + Backup_Duration;
               delay until Action_Complete_Time;

               -- Action 2: Stop (for a crisp turn)
               MotorDriver.Drive(Stop);
               Action_Complete_Time := Clock + Short_Pause;
               delay until Action_Complete_Time;

               -- Action 3: Turn Right 90 degrees (Pivot Turn)
               Put_Line("=> Turning RIGHT 90");
               MotorDriver.Drive(Rotating_Right, (4095, 4095, 4095, 4095));
               Action_Complete_Time := Clock + Turn_90_Duration;
               delay until Action_Complete_Time;

               -- Action 4: Stop (Good practice before next loop)
               MotorDriver.Drive(Stop);

            -- === THIS LOGIC IS NEW ===
            elsif Right_Blocked and not Left_Blocked then
               -- SCENARIO 2: OBSTACLE ON RIGHT
               Put_Line("Obstacle on RIGHT, stopping to turn LEFT");

               -- Action 1: Stop
               MotorDriver.Drive(Stop);
               Action_Complete_Time := Clock + Short_Pause;
               delay until Action_Complete_Time;

               -- Action 2: Pivot Left 90 degrees
               MotorDriver.Drive(Rotating_Left, (4095, 4095, 4095, 4095));
               Action_Complete_Time := Clock + Turn_90_Duration;
               delay until Action_Complete_Time;

               -- Action 3: Stop (Good practice)
               MotorDriver.Drive(Stop);

            -- === THIS LOGIC IS NEW ===
            elsif Left_Blocked and not Right_Blocked then
               -- SCENARIO 3: OBSTACLE ON LEFT
               Put_Line("Obstacle on LEFT, stopping to turn RIGHT");

               -- Action 1: Stop
               MotorDriver.Drive(Stop);
               Action_Complete_Time := Clock + Short_Pause;
               delay until Action_Complete_Time;

               -- Action 2: Pivot Right 90 degrees
               MotorDriver.Drive(Forward, (4095, 4095, 0, 0));
               Action_Complete_Time := Clock + Turn_90_Duration;
               delay until Action_Complete_Time;

               -- Action 3: Stop (Good practice)
               MotorDriver.Drive(Stop);

            else
               -- SCENARIO 4: CRUISE (Both are clear)
               Put_Line("Clear - Moving forward");
               MotorDriver.Drive(Forward, (4095, 4095, 4095, 4095));
            end if;
         end;

         -- Wait for the next logic cycle
         Next_Release := Next_Release + Period;
         delay until Next_Release;

      end loop;
   end Logic_Controller;
end Logic_Task;

-- This file is mostly unchanged from the example
-- I just updated variable names to match the new shared_data buffer.

--  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

--  with Ada.Real_Time; use Ada.Real_Time;
--  with MicroBit.Types; use MicroBit.Types;
--  with MicroBit.MotorDriver; use MicroBit.MotorDriver;
--  with DFR0548;
--  with MicroBit.Console; use MicroBit.Console;
--  use MicroBit;
--  with Shared_Data;
--  with Config;

--  package body Logic_Task is
--     -- ... (Timing constants remain the same) [cite: 5, 6]
--     Servo_Settle_Time : constant Time_Span := Milliseconds(400);
--     Turn_90_Duration  : constant Time_Span := Milliseconds(700);
--     Turn_180_Duration : constant Time_Span := Milliseconds(1400);
--     Backup_Duration   : constant Time_Span := Milliseconds(1000);
--     Short_Pause       : constant Time_Span := Milliseconds(200);

--     task body Logic_Controller is
--        Period : constant Time_Span := Config.Logic_Period;
--        Next_Release : Time := Clock;

--        -- MODIFIED: Renamed variables for clarity
--        Distance_Right : Distance_cm;
--        Distance_Left  : Distance_cm;
--        Distance_Scan  : Distance_cm;
--        Dummy : Distance_cm;

--        Threshold : constant Distance_cm := Distance_cm(15.0);
--        Action_Complete_Time : Time;
--     begin
--        Put_Line("=== INTELLIGENT CAR (Full Real_Time) ===");
--        MotorDriver.Servo(1, 90);
--        Action_Complete_Time := Clock + Servo_Settle_Time;
--        delay until Action_Complete_Time;

--        loop
--           -- MODIFIED: Updated variable names
--           Shared_Data.Sensor_Buffer.Get_Distances(Distance_Right, Distance_Left);
--           if Distance_Right < Threshold or Distance_Left < Threshold then
--              Put_Line("OBSTACLE! R=" & Distance_cm'Image(Distance_Right) &
--                       " L=" & Distance_cm'Image(Distance_Left));

--              MotorDriver.Drive(Stop);
--              Action_Complete_Time := Clock + Short_Pause;
--              delay until Action_Complete_Time;

--              -- SKANN VENSTRE
--              Put_Line("Scanning LEFT...");
--              MotorDriver.Servo(1, 180);
--              Action_Complete_Time := Clock + Servo_Settle_Time;
--              delay until Action_Complete_Time;

--              Shared_Data.Sensor_Buffer.Get_Distances(Dummy, Distance_Scan);
--              Put_Line("  Scan Left: " & Distance_cm'Image(Distance_Scan) & " cm");

--              if Distance_Scan > Threshold then
--                 -- VENSTRE ER ÅPEN
--                 Put_Line("=> Turning LEFT");
--                 MotorDriver.Servo(1, 90);
--                 Action_Complete_Time := Clock + Short_Pause;
--                 delay until Action_Complete_Time;

--                 MotorDriver.Drive(Rotating_Left, (4095, 4095, 4095, 4095));
--                 Action_Complete_Time := Clock + Turn_90_Duration;
--                 delay until Action_Complete_Time;

--              else
--                 -- VENSTRE BLOKKERT - SKANN HØYRE
--                 Put_Line("Scanning RIGHT...");
--                 MotorDriver.Servo(1, 0);
--                 Action_Complete_Time := Clock + Servo_Settle_Time;
--                 delay until Action_Complete_Time;

--                 Shared_Data.Sensor_Buffer.Get_Distances(Distance_Scan, Dummy);
--                 Put_Line("  Scan Right: " & Distance_cm'Image(Distance_Scan) & " cm");

--                 if Distance_Scan > Threshold then
--                    -- HØYRE ER ÅPEN
--                    Put_Line("=> Turning RIGHT");
--                    MotorDriver.Servo(1, 90);
--                    Action_Complete_Time := Clock + Short_Pause;
--                    delay until Action_Complete_Time;

--                    MotorDriver.Drive(Rotating_Right, (4095, 4095, 4095, 4095));
--                    Action_Complete_Time := Clock + Turn_90_Duration;
--                    delay until Action_Complete_Time;

--                 else
--                    -- BEGGE BLOKKERT - RYGGE!
--                    Put_Line("=> BACKING UP (all blocked)");
--                    MotorDriver.Servo(1, 90);
--                    Action_Complete_Time := Clock + Short_Pause;
--                    delay until Action_Complete_Time;

--                    MotorDriver.Drive(Backward, (4095, 4095, 4095, 4095));
--                    Action_Complete_Time := Clock + Backup_Duration;
--                    delay until Action_Complete_Time;

--                    -- Snu 180 grader
--                    Put_Line("=> Turning around");
--                    MotorDriver.Drive(Rotating_Right, (4095, 4095, 4095, 4095));
--                    Action_Complete_Time := Clock + Turn_180_Duration;
--                    delay until Action_Complete_Time;
--                 end if;
--              end if;
--           else
--              Put_Line("Clear - Moving forward");
--              MotorDriver.Drive(Forward, (4095, 4095, 4095, 4095));
--           end if;

--           Next_Release := Next_Release + Period;
--           delay until Next_Release;
--        end loop;
--     end Logic_Controller;
--  end Logic_Task;
