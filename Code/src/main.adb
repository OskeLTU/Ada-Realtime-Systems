--  ------------------------------------------------------------------------------
--  --                                                                          --
--  --                       Copyright (C) 2019, AdaCore                        --
--  --                                                                          --
--  --  Redistribution and use in source and binary forms, with or without      --
--  --  modification, are permitted provided that the following conditions are  --
--  --  met:                                                                    --
--  --     1. Redistributions of source code must retain the above copyright    --
--  --        notice, this list of conditions and the following disclaimer.     --
--  --     2. Redistributions in binary form must reproduce the above copyright --
--  --        notice, this list of conditions and the following disclaimer in   --
--  --        the documentation and/or other materials provided with the        --
--  --        distribution.                                                     --
--  --     3. Neither the name of the copyright holder nor the names of its     --
--  --        contributors may be used to endorse or promote products derived   --
--  --        from this software without specific prior written permission.     --
--  --                                                                          --
--  --   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--  --   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--  --   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--  --   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--  --   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--  --   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--  --   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--  --   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--  --   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--  --   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--  --   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--  --                                                                          --
--  ------------------------------------------------------------------------------

with HAL;
with Interfaces.C;
with Microbit.IOsForTasking;  use MicroBit.IOsForTasking;
with Microbit.Ultrasonic;
with Microbit.Console; use MicroBit.Console;
with Microbit.Types; use MicroBit.Types;
use MicroBit;
with Microbit;
with MicroBit.MotorDriver; use MicroBit.MotorDriver; --using the procedures defined here
with DFR0548;  -- using the types defined here




procedure Main is

   wrong_way : exception;

   package sensor1 is new Ultrasonic(MB_P16, MB_P15);
   package sensor2 is new Ultrasonic(MB_P14, MB_P13);

   function Read_right_sensor return Distance_cm is
   Distance_sensor_1 : Distance_cm;

   begin
      Distance_sensor_1 := sensor1.Read;
      return Distance_sensor_1;
   end Read_right_sensor;

   function Read_left_sensor return Distance_cm is


   Distance_sensor_2 : Distance_cm;
   begin
      Distance_sensor_2 := sensor2.Read;
      return Distance_sensor_2;
   end Read_left_sensor;

   Base_speed : constant Float := 4096.0;
   KP         : constant Float := 500.0;  -- Proportional gain

   begin
         loop
      declare
         -- This block now ONLY handles sensor reading and initial calculation
         Current_distance_right : Distance_cm;
         Current_distance_left  : Distance_cm;
         Distance_difference    : Float;
      begin
         Current_distance_right := Read_right_sensor;
         Current_distance_left  := Read_left_sensor;
         Distance_difference    := Float(Current_distance_left) - Float(Current_distance_right);

         -- If we successfully get here, the sensor data is good.
         -- Now we can proceed to the motor calculations in their own safe block.
         declare
            -- This block ONLY handles motor calculations
            Correction  : constant Float := KP * Distance_difference;
            Left_speed  : Float := Base_speed + Correction;
            Right_speed : Float := Base_speed - Correction;

            procedure Speed_Bound (Speed : in out Float) is
               Max_speed : constant Float := 4095.0;
            begin
               if Speed > Max_speed then
                  Speed := Max_speed;
               elsif Speed < 0.0 then
                  Speed := 0.0;
               end if;
            end Speed_Bound;

         begin
            Speed_Bound(Left_speed);
            Speed_Bound(Right_speed);

            declare
               Final_Left_Speed  : constant Integer := Integer(Left_speed);
               Final_Right_Speed : constant Integer := Integer(Right_speed);
            begin
               MotorDriver.Drive
                 (Forward,
                  (HAL.UInt12(Final_Right_Speed),
                   HAL.UInt12(Final_Right_Speed),
                   HAL.UInt12(Final_Left_Speed),
                   HAL.UInt12(Final_Left_Speed)));
            end;
         exception
            -- This handler ONLY catches errors during motor calculations
            when others =>
               MotorDriver.Drive(Stop);
               Put_Line ("!!! EXCEPTION IN MOTOR CALCULATION !!!");
               delay 2.0;
         end;

      exception
         -- This handler ONLY catches errors during sensor reading
         when others =>
            MotorDriver.Drive(Stop);
            Put_Line ("!!! EXCEPTION DURING SENSOR READ !!!");
            delay 2.0;
      end;
      delay 0.05;
   end loop;

end Main;
