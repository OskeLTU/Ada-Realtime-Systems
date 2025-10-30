with Microbit.types; use Microbit.Types;
with Microbit.Ultrasonic;
with HAL; use HAL;
with nRF.GPIO; use nRF.GPIO;
with Microbit.Types; use MicroBit.Types;
with Ada.Real_Time; use Ada.Real_Time;

package body Sensors is



package sensor1 is new Ultrasonic(MB_P16, MB_P15);
package sensor2 is new Ultrasonic(MB_P14, MB_P13);

protected sensor_values is
   procedure Trig_left;
   procedure Trig_right;

   procedure Echo_left;
   procedure Echo_right;

   pragma Attach_Handler(Echo_left, Ada.Interrupts.Names.Echo_left_interrupt);
   pragma Attach_Handler(Echo_right, Ada.Interrupts.Names.Echo_right_interrupt);

   function Left_Distance return Distance_cm;
   function Right_Distance return Distance_cm;

private
   Left_value  : Distance_cm := 0;
   Right_value : Distance_cm := 0;
end sensor_values;

protected body sensor_values is

   procedure Trig_left is
   begin
      Trig_left.Set;
      Delay_Us(10);
      Trig_left.Clear;
   end Trig_left;

   procedure Trig_right is
   begin
      Trig_right.Set;
      Delay_Us(10);
      Trig_right.Clear;
   end Trig_right;

   procedure Echo_left is
   begin
      null; -- Placeholder for echo handling if needed
   end Echo_left;

   procedure Echo_right is
   begin
      null; -- Placeholder for echo handling if needed
   end Echo_right;

   function Left_Distance return Distance_cm is
   begin
      return Left_value;
   end Left_Distance;

   function Right_Distance return Distance_cm is
   begin
      return Right_value;
   end Right_Distance;

end sensor_values;

end Sensors;

