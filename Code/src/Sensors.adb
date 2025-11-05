with Microbit.types; use Microbit.Types;
with Microbit.Ultrasonic;
with HAL; use HAL;
with nRF.GPIO; use nRF.GPIO;
with Microbit.Types; use MicroBit.Types;
with Ada.Real_Time; use Ada.Real_Time;


package body Sensors is

Trigger_left_pin : constant GPIO_Pin   := MB_P14;
Trigger_right_pin : constant GPIO_Pin  := MB_P16;
Echo_left_pin    : constant GPIO_Pin   := MB_P13;
Echo_right_pin   : constant GPIO_Pin   := MB_P15;

protected sensor_values is

   procedure Timer_start_left;
   procedure Timer_start_right;
   procedure Timer_stop_left;
   procedure Timer_stop_right;


   function Left_Distance return Distance_cm;
   function Right_Distance return Distance_cm;

private
   Left_value, Right_value : Distance_cm := 0;
   Left_timer_start        : Time := Clock;
   Right_timer_start       : Time := Clock;

end sensor_values;

protected body sensor_values is

   procedure Timer_start_left is
   begin
      Left_timer_start := Clock;
   end Timer_start_left;

   procedure Timer_stop_left is
   Duration : Time_Span;
   begin
      Duration := Clock - Left_timer_start;
      Left_value := Distance_cm(Integer(To_Milliseconds(Duration))* 0.0343/2.0);
   end Timer_stop_left;

   procedure Timer_start_right is
   begin
      Right_timer_start := Clock;
   end Timer_start_right;

   procedure Timer_stop_right is
   Duration : Time_Span;
   begin
      Duration := Clock - Right_timer_start;
      Right_value := Distance_cm(Integer(To_Milliseconds(Duration))* 0.0343/2.0);
   end Timer_stop_right;

   function Left_Distance return Distance_cm is
   begin
      return Left_value;
   end Left_Distance;

   function Right_Distance return Distance_cm is
   begin
      return Right_value;
   end Right_Distance;

end sensor_values;

procedure sensor_control_setup is
begin

Configure(Trigger_left_pin, GPIO_Output);
Configure(Trigger_right_pin, GPIO_Output);
Configure(Echo_left_pin, GPIO_Input);
Configure(Echo_right_pin, GPIO_Input);

Clear (Trigger_left_pin);
Clear (Trigger_right_pin);

Attach_Handler(Echo_left_pin, Rising_Edge, sensor_values.Timer_start_left'Access);
Attach_Handler(Echo_left_pin, Falling_Edge, sensor_values.Timer_stop_left'Access);
Attach_Handler(Echo_right_pin, Rising_Edge, sensor_values.Timer_start_right'Access);
Attach_Handler(Echo_right_pin, Falling_Edge, sensor_values.Timer_stop_right'Access);

delay 0.1;

end sensor_control_setup;

procedure Trig_left is
begin
   Set(Trigger_left_pin);
   delay 0.00001;
   Clear(Trigger_left_pin);
end Trig_left;

procedure Trig_right is
begin
   Set(Trigger_right_pin);
   delay 0.00001;
   Clear(Trigger_right_pin);
end Trig_right;

function Left_Distance return Distance_cm is
begin
   Trig_left;
   delay 0.05;
   return sensor_values.Left_Distance;
end Left_Distance;

function Right_Distance return Distance_cm is
begin
   Trig_right;
   delay 0.05;
   return sensor_values.Right_Distance;
end Right_Distance;

end Sensors;


